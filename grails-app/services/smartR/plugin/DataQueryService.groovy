package smartR.plugin

import org.transmartproject.rest.marshallers.ObservationWrapper
import org.transmartproject.core.ontology.OntologyTerm
import org.transmartproject.core.dataquery.clinical.*
import org.transmartproject.core.dataquery.TabularResult
import org.springframework.beans.factory.annotation.Autowired
import org.transmartproject.core.dataquery.DataRow
import org.transmartproject.core.dataquery.TabularResult
import org.transmartproject.core.dataquery.highdim.AssayColumn
import org.transmartproject.core.dataquery.highdim.HighDimensionDataTypeResource
import org.transmartproject.core.dataquery.highdim.HighDimensionResource
import org.transmartproject.core.dataquery.highdim.assayconstraints.AssayConstraint
import org.transmartproject.core.dataquery.highdim.dataconstraints.DataConstraint
import org.transmartproject.core.dataquery.highdim.projections.Projection

class DataQueryService {

    def studiesResourceService
    def conceptsResourceService
    def clinicalDataResourceService
    def dataSource
    def i2b2HelperService
    @Autowired
    HighDimensionResource highDimensionResource

    def getAllData(conceptKeys, patientIDs) {
        def data = []
        conceptKeys.each { conceptKey ->
            def concept = conceptsResourceService.getByKey(conceptKey)
            def study = studiesResourceService.getStudyById(concept.studyId)

            def observations
            def wrappedObservations
            try {
                observations = clinicalDataResourceService.retrieveData(
                    concept.patients.toSet(),
                    [createClinicalVariable(concept)])
                wrappedObservations = wrapObservations(observations)
            } finally {
                observations.close()
            }

            def values = wrappedObservations
                .findAll { it.subject.id in patientIDs }
                .collect { it.value }

            def ids = concept.patients
                .findAll { it.id in patientIDs }
                .collect { it.id }

            assert values.size() == ids.size()

            [values, ids].transpose().each { value, id ->
                data << [patientID: id, concept: conceptKey, value: value]
            }
        }
        return data
    }

    def exportHighDimData(conceptKeys, patientIDs, resultInstanceId) {
        def data = [PATIENTID: [], VALUE: [], PROBE: [], GENESYMBOL: []]

        Map<String, HighDimensionDataTypeResource> highDimDataTypeResourceCache = [:]
        conceptKeys.each { conceptKey ->
            highDimDataTypeResourceCache[conceptKey] = getHighDimDataTypeResourceFromConcept(conceptKey)
        }

        TabularResult tabularResult
        highDimDataTypeResourceCache.each {conceptKey, dataTypeResource ->
            tabularResult = fetchData(resultInstanceId, conceptKey, dataTypeResource)

            def assayList = tabularResult.indicesList
            tabularResult.each { DataRow row ->
                assayList.each {AssayColumn assayColumn ->
                    data.PATIENTID << assayColumn.patient.id
                    data.VALUE << row[assayColumn]
                    data.PROBE << row.label
                    data.GENESYMBOL << row.bioMarker
                }
            }

            tabularResult.close()
        }

        return data
    }

    private HighDimensionDataTypeResource getHighDimDataTypeResourceFromConcept(String conceptKey) {
        def constraints = []

        constraints << highDimensionResource.createAssayConstraint(
                AssayConstraint.DISJUNCTION_CONSTRAINT,
                subconstraints: [
                        (AssayConstraint.ONTOLOGY_TERM_CONSTRAINT):
                                [concept_key: conceptKey]])

        def assayMultiMap = highDimensionResource.
                getSubResourcesAssayMultiMap(constraints)

        HighDimensionDataTypeResource dataTypeResource = assayMultiMap.keySet()[0]
        return dataTypeResource
    }

    private TabularResult fetchData(Long patientSetId, String ontologyTerm,
                                    HighDimensionDataTypeResource dataTypeResource) {

        List<AssayConstraint> assayConstraints = []
        assayConstraints.add(
                dataTypeResource.createAssayConstraint(
                        AssayConstraint.PATIENT_SET_CONSTRAINT,
                        result_instance_id: patientSetId))
        assayConstraints.add(
                dataTypeResource.createAssayConstraint(
                        AssayConstraint.ONTOLOGY_TERM_CONSTRAINT,
                        concept_key: ontologyTerm))

        List<DataConstraint> dataConstraints = []

        Projection projection = dataTypeResource.createProjection([:], Projection.DEFAULT_REAL_PROJECTION)

        dataTypeResource.retrieveData(assayConstraints, dataConstraints, projection)
    }


    private ClinicalVariable createClinicalVariable(OntologyTerm term) {
        clinicalDataResourceService.createClinicalVariable(
                ClinicalVariable.NORMALIZED_LEAFS_VARIABLE,
                concept_path: term.fullName)
    }

    private static List<ObservationWrapper> wrapObservations(
        TabularResult<ClinicalVariable, PatientRow> tabularResult) {
        List<ObservationWrapper> observations = []
        def variableColumns = tabularResult.getIndicesList()
        tabularResult.getRows().each { row ->
            variableColumns.each { ClinicalVariableColumn topVar ->
                def value = row.getAt(topVar)

                if (value instanceof Map) {
                    value.each { ClinicalVariableColumn var, Object obj ->
                        observations << new ObservationWrapper(
                                subject: row.patient,
                                label: var.label,
                                value: obj)
                    }
                } else {
                    observations << new ObservationWrapper(
                            subject: row.patient,
                            label: topVar.label,
                            value: value)
                }
            }
        }
        return observations
    }
}
