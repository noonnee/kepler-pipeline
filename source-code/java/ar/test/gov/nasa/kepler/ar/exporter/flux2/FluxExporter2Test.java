/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.ar.exporter.flux2;

import gov.nasa.kepler.ar.archive.BackgroundPixelValue;
import gov.nasa.kepler.ar.exporter.PerTargetExporterTestUtils;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.FsIdSetMatcher;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.PdcBand;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcGoodnessComponentType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcGoodnessMetricType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.pi.OriginatorsModelRegistryChecker;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.*;

import org.hamcrest.TypeSafeMatcher;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Maps;

@RunWith(JMock.class)
public class FluxExporter2Test extends PerTargetExporterTestUtils {

    private Mockery mockery;
    private final File exportDirectory = 
        new File(Filenames.BUILD_TEST, "FluxExporter2Test");

    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        FileUtil.cleanDir(exportDirectory);
        FileUtil.mkdirs(exportDirectory);
    }

    @After
    public void tearDown() throws Exception {
        // FileUtil.cleanDir(exportDirectory);
    }

    @Test
    public void testFluxExporter2() throws Exception {
        final ConfigMap configMap = configureConfigMap(mockery);

        final FileStoreClient fsClient = createFileStoreClient(allTargetPixels,
            ccdModule, ccdOutput, originator, startCadence, endCadence,
            keplerIds, timestampSeries, ttableExternalId, referenceCadence);

        final MjdToCadence mjdToCadence = createMjdToCadence(mockery, timestampSeries, cadenceType);

        final PipelineTask pipelineTask = createPipelineTask(mockery);

        final ObservedTarget observedTarget = createKicObservedTarget(mockery,
            pipelineTask);

        final ObservedTarget customObservedTarget = createCustomObservedTarget(
            mockery, pipelineTask);

        final SciencePixelOperations sciOps = createSciencePixelOperations(
            mockery, observedTarget, customObservedTarget);

        final Map<Pixel, BackgroundPixelValue> background = new HashMap<Pixel, BackgroundPixelValue>();
        for (Pixel pixel : allTargetPixels) {
            BackgroundPixelValue backgroundPixelValue = new BackgroundPixelValue(
                2, 1, new double[cadenceLength], new boolean[cadenceLength],
                new double[cadenceLength], new boolean[cadenceLength]);
            background.put(pixel, backgroundPixelValue);
        }

        final OriginatorsModelRegistryChecker originatorsModelRegistryChecker = createOmrc(mockery);

        final FluxExporterSource source = mockery.mock(FluxExporterSource.class);
        commonSourceExpectations(mockery, source, configMap, exportDirectory,
            fsClient, mjdToCadence, sciOps, observedTarget,
            customObservedTarget, originatorsModelRegistryChecker, false);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).k2Campaign();
            will(returnValue(-1));
        }});

        addTpsResultsExpectations(mockery, source);
        addWcsExpectations(mockery, source);
        
        final Map<Integer, PdcProcessingCharacteristics> keplerIdToPdcC = Maps.newHashMap();
        
        for (Integer keplerId : keplerIds) {
            List<PdcBand> bands = ImmutableList.of(new PdcBand("prior", 1.0f, 2.0f), new PdcBand("robust", 0f, 0f));
            
            PdcProcessingCharacteristics pdcChar =
                new PdcProcessingCharacteristics("multiscaleMap",
                    42, 33, false, false, 5.0f, bands);
            keplerIdToPdcC.put(keplerId, pdcChar);
        }
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).pdcProcessingCharacteristics();
            will(returnValue(keplerIdToPdcC));
        }});
        
        FluxExporter2 fluxExporter2 = new FluxExporter2();
        fluxExporter2.exportLightCurves(source);

    }

    /**
     * This will create data that is one less cadence that the specified start
     * and end. This is to simulate targets that have truncated data for
     * whatever reason.
     * 
     * @param targetPixels
     * @param ccdModule
     * @param ccdOutput
     * @param originator
     * @param startCadence
     * @param endCadence
     * @param keplerId
     * @param timestampSeries
     * @param ttableExternalId
     * @return
     */
    @SuppressWarnings("unchecked")
    private FileStoreClient createFileStoreClient(SortedSet<Pixel> allPixels,
        int ccdModule, int ccdOutput, long originator, final int startCadence,
        final int endCadence, List<Integer> keplerIds,
        TimestampSeries timestampSeries, int ttableExternalId,
        int referenceCadence) {

        final ImmutableMap.Builder<FsId, TimeSeries> idToTimeSeries = new ImmutableMap.Builder<FsId, TimeSeries>();
        final ImmutableMap.Builder<FsId, FloatMjdTimeSeries> idToMjdTimeSeries = new ImmutableMap.Builder<FsId, FloatMjdTimeSeries>();
        final ImmutableSet.Builder<FsId> timeSeriesIds = new ImmutableSet.Builder<FsId>();
        final ImmutableSet.Builder<FsId> mjdTimeSeriesIds = new ImmutableSet.Builder<FsId>();

        final int nCadences = endCadence - startCadence + 1;
        final double midStartMjd = timestampSeries.midTimestamps[0];
        final double midEndMjd = timestampSeries.midTimestamps[timestampSeries.midTimestamps.length - 1];

        boolean[] totallyGapped = new boolean[nCadences];
        Arrays.fill(totallyGapped, true);
        
        //immutable set builder does not like duplicates.
        Map<FsId, IntTimeSeries> rollingBandFlags = Maps.newHashMap();
        for (Pixel pixel : allPixels) {
            if (!pixel.isInOptimalAperture()) {
                continue;
            }
            
            FsId cosmicRay = PaFsIdFactory.getCosmicRaySeriesFsId(
                TargetType.LONG_CADENCE, ccdModule, ccdOutput, pixel.getRow(),
                pixel.getColumn());
            FloatMjdTimeSeries crseries = new FloatMjdTimeSeries(cosmicRay,
                midStartMjd, midEndMjd,
                new double[] { timestampSeries.midTimestamps[1] },
                new float[1], originator);
            idToMjdTimeSeries.put(cosmicRay, crseries);
            mjdTimeSeriesIds.add(cosmicRay);
        }

        idToTimeSeries.putAll(rollingBandFlags);
        timeSeriesIds.addAll(rollingBandFlags.keySet());
        
        int dataColumnCount = 0;
        for (int keplerId : keplerIds) {
            FsId discontinuity = PdcFsIdFactory.getDiscontinuityIndicesFsId(
                FluxType.SAP, CadenceType.LONG, keplerId);
            idToTimeSeries.put(
                discontinuity,
                generateIntTimeSeries(1, discontinuity, originator,
                    startCadence, endCadence));
            FsId pdcOutlierId = PdcFsIdFactory.getOutlierTimerSeriesId(
                PdcOutliersTimeSeriesType.OUTLIERS, FluxType.SAP,
                CadenceType.LONG, keplerId);
            idToMjdTimeSeries.put(pdcOutlierId, new FloatMjdTimeSeries(
                pdcOutlierId, midStartMjd, midEndMjd,
                new double[] { timestampSeries.midTimestamps[1] },
                new float[1], originator));
            FsId pdcOutlierUmmId = PdcFsIdFactory.getOutlierTimerSeriesId(
                PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES, FluxType.SAP,
                cadenceType, keplerId);
            idToMjdTimeSeries.put(pdcOutlierUmmId, new FloatMjdTimeSeries(
                pdcOutlierUmmId, midStartMjd, midEndMjd,
                new double[] { timestampSeries.midTimestamps[1] },
                new float[] { 3.14f }, originator));

            FsId pdcFilledId = PdcFsIdFactory.getFilledIndicesFsId(
                PdcFilledIndicesTimeSeriesType.FILLED_INDICES, FluxType.SAP,
                cadenceType, keplerId);
            idToTimeSeries.put(pdcFilledId, new IntTimeSeries(pdcFilledId,
                new int[nCadences], startCadence, endCadence,
                Collections.EMPTY_LIST, Collections.EMPTY_LIST));

            mjdTimeSeriesIds.add(pdcOutlierId).add(pdcOutlierUmmId);
            timeSeriesIds.add(discontinuity).add(pdcFilledId);

            for (TimeSeriesType fluxTimeSeriesType : TimeSeriesType.values()) {
                FsId id = PaFsIdFactory.getTimeSeriesFsId(
                    fluxTimeSeriesType, FluxType.SAP, cadenceType, keplerId);
                switch (fluxTimeSeriesType) {
                    case CROWDING_METRIC:
                    case FLUX_FRACTION_IN_APERTURE:
                    case SIGNAL_TO_NOISE_RATIO:
                    case SKY_CROWDING_METRIC:
                        idToTimeSeries.put(
                            id,
                            generateDoubleTimeSeries(id, dataColumnCount++,
                                false, originator, startCadence, endCadence));
                        break;
                    default:
                        idToTimeSeries.put(
                            id,
                            generateFloatTimeSeries(id, dataColumnCount++,
                                false, startCadence, endCadence));
                        break;
                }
                timeSeriesIds.add(id);
            }

            for (PdcFluxTimeSeriesType timeSeriesType : ImmutableList.of(
                PdcFluxTimeSeriesType.CORRECTED_FLUX,
                PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES)) {
                FsId id = PdcFsIdFactory.getFluxTimeSeriesFsId(timeSeriesType,
                    FluxType.SAP, cadenceType, keplerId);
                idToTimeSeries.put(
                    id,
                    generateFloatTimeSeries(id, dataColumnCount++, false,
                        startCadence, endCadence));
                timeSeriesIds.add(id);
            }

            boolean emptyCentroids = TargetManagementConstants.isCustomTarget(keplerId);
            for (CentroidType centroidType : CentroidType.values()) {
                for (CentroidTimeSeriesType timeSeriesType : CentroidTimeSeriesType.values()) {
                    FsId id = PaFsIdFactory.getCentroidTimeSeriesFsId(
                        FluxType.SAP, centroidType, timeSeriesType,
                        cadenceType, keplerId);
                    timeSeriesIds.add(id);

                    if (timeSeriesType.getName().toLowerCase().contains("uncert")) {
                        idToTimeSeries.put(
                            id,
                            generateFloatTimeSeries(id, dataColumnCount++,
                                emptyCentroids, startCadence, endCadence));
                    } else {
                        idToTimeSeries.put(
                            id,
                            generateDoubleTimeSeries(id, dataColumnCount++,
                                emptyCentroids, originator, startCadence, endCadence));
                    }
                }
            }

            Collection<TimeSeries> pdcMapSeries = 
                generatePdcMapTimeSeries(keplerId, startCadence, endCadence, originator);
            
            for (TimeSeries ts : pdcMapSeries) {
                idToTimeSeries.put(ts.id(), ts);
                timeSeriesIds.add(ts.id());
            }
        }

        Map<FsId, FloatMjdTimeSeries> collateralCosmicRays = 
            collateralCosmicRays(originator, timestampSeries, targetPixels,
                keepOptimalAperture, cadenceType);
        mjdTimeSeriesIds.addAll(collateralCosmicRays.keySet());

        idToMjdTimeSeries.putAll(collateralCosmicRays);

        IntTimeSeries paArgabrightening = generatePaArgabrighteningTimeSeries(
            startCadence, endCadence, referenceCadence, ttableExternalId,
            ccdModule, ccdOutput, originator);
        idToTimeSeries.put(paArgabrightening.id(), paArgabrightening);
        timeSeriesIds.add(paArgabrightening.id());

        IntTimeSeries zeroCrossings = generateZeroCrossingsTimeSeries(
            startCadence, endCadence, cadenceType, originator);
        idToTimeSeries.put(zeroCrossings.id(), zeroCrossings);
        timeSeriesIds.add(zeroCrossings.id());
        
        Pair<IntTimeSeries, IntTimeSeries> thrusterFirings = 
            generateThrusterFiringTimeSeries(startCadence, endCadence, cadenceType, originator);
        idToTimeSeries.put(thrusterFirings.left.id(), thrusterFirings.left);
        timeSeriesIds.add(thrusterFirings.left.id());
        idToTimeSeries.put(thrusterFirings.right.id(), thrusterFirings.right);
        timeSeriesIds.add(thrusterFirings.right.id());
        
        final TypeSafeMatcher<List<FsIdSet>> timeSeriesIdSetMatcher = new FsIdSetMatcher(
            Collections.singletonList(new FsIdSet(startCadence, endCadence,
                new TreeSet<FsId>(timeSeriesIds.build()))));
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        mockery.checking(new Expectations() {
            {
                one(fsClient).readTimeSeriesBatch(with(timeSeriesIdSetMatcher),
                    with(equals(false)));
                will(returnValue(Collections.singletonList(new TimeSeriesBatch(
                    startCadence, endCadence, idToTimeSeries.build()))));

                one(fsClient).readMjdTimeSeriesBatch(
                    Collections.singletonList(new MjdFsIdSet(midStartMjd,
                        midEndMjd, new TreeSet<FsId>(mjdTimeSeriesIds.build()))));
                will(returnValue(Collections.singletonList(new MjdTimeSeriesBatch(
                    midStartMjd, midEndMjd, idToMjdTimeSeries.build()))));

            }
        });
        
        final Set<FsId> rollingBandFlagIds = new HashSet<FsId>();
        final Map<FsId, TimeSeries> rollingBandFlagReturnValue = Maps.newHashMap();
        rollingBandFlagTimeSeries(rollingBandFlagIds, rollingBandFlagReturnValue, allPixels);
        mockery.checking(new Expectations() {{
            one(fsClient).readTimeSeries(rollingBandFlagIds, startCadence, endCadence, false);
            will(returnValue(rollingBandFlagReturnValue));
        }});
        return fsClient;
    }

    private static Collection<TimeSeries> generatePdcMapTimeSeries(int keplerId,
        int startCadence, int endCadence, long originator) {

        
        int fillValue = 1;
        FsId pdcEarthPointFsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
                PdcGoodnessMetricType.EARTH_POINT_REMOVAL, PdcGoodnessComponentType.VALUE,
                FluxType.SAP, CadenceType.LONG, keplerId);
        TimeSeries earthPointGoodness = 
            generateFloatTimeSeries(fillValue++, pdcEarthPointFsId, 
                originator, startCadence, endCadence);
        
        FsId pdcEarthPointPctFsId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
                PdcGoodnessMetricType.EARTH_POINT_REMOVAL, PdcGoodnessComponentType.PERCENTILE,
                FluxType.SAP, CadenceType.LONG, keplerId);
        TimeSeries earthPointPct = 
            generateFloatTimeSeries(fillValue++, pdcEarthPointPctFsId, 
                originator, startCadence, endCadence);
        
        FsId pdcMapCorrelationGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.CORRELATION, PdcGoodnessComponentType.VALUE,
            FluxType.SAP, CadenceType.LONG, keplerId);
        TimeSeries correlationGoodness = 
            generateFloatTimeSeries(fillValue++, pdcMapCorrelationGoodnessId, 
                originator, startCadence, endCadence);
        
        FsId pdcMapCorrelationGoodnessPctId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.CORRELATION,
            PdcGoodnessComponentType.PERCENTILE, FluxType.SAP, CadenceType.LONG,
            keplerId);
        TimeSeries correlationGoodnessPct = 
            generateFloatTimeSeries(fillValue++, pdcMapCorrelationGoodnessPctId, 
                originator, startCadence, endCadence);
        
        FsId pdcMapVariabilityGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.DELTA_VARIABILITY,
            PdcGoodnessComponentType.VALUE, FluxType.SAP, CadenceType.LONG, keplerId);
        TimeSeries variabilityGoodness = 
            generateFloatTimeSeries(fillValue++, pdcMapVariabilityGoodnessId, 
                originator, startCadence, endCadence);
        
        FsId pdcMapVariabilityGoodnessPctId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.DELTA_VARIABILITY,
            PdcGoodnessComponentType.PERCENTILE, FluxType.SAP, CadenceType.LONG,
            keplerId);
        TimeSeries variabilityGoodnessPct = 
            generateFloatTimeSeries(fillValue++, pdcMapVariabilityGoodnessPctId, 
                originator, startCadence, endCadence);
        
        FsId pdcMapNoiseGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.INTRODUCED_NOISE,
            PdcGoodnessComponentType.VALUE, FluxType.SAP, CadenceType.LONG, keplerId);
        TimeSeries noiseGoodness = 
            generateFloatTimeSeries(fillValue++, pdcMapNoiseGoodnessId, 
                originator, startCadence, endCadence);
        
        FsId pdcMapNoiseGoodnessPctId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.INTRODUCED_NOISE,
            PdcGoodnessComponentType.PERCENTILE, FluxType.SAP, CadenceType.LONG,
            keplerId);
        TimeSeries noiseGoodnessPct = 
            generateFloatTimeSeries(fillValue++, pdcMapNoiseGoodnessPctId, 
                originator, startCadence, endCadence);
        
        FsId pdcMapTotalGoodnessId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.TOTAL, PdcGoodnessComponentType.VALUE,
            FluxType.SAP, CadenceType.LONG, keplerId);
        TimeSeries totalGoodness = 
            generateFloatTimeSeries(fillValue++, pdcMapTotalGoodnessId, 
                originator, startCadence, endCadence);
        
        FsId pdcMapTotalGoodnessPctId = PdcFsIdFactory.getPdcGoodnessMetricFsId(
            PdcGoodnessMetricType.TOTAL, PdcGoodnessComponentType.PERCENTILE,
            FluxType.SAP, CadenceType.LONG, keplerId);
        TimeSeries totalGoodnessPct = 
            generateFloatTimeSeries(fillValue++, pdcMapTotalGoodnessPctId, 
                originator, startCadence, endCadence);
        
        
        return ImmutableSet.of(earthPointGoodness, earthPointPct, 
            variabilityGoodness, variabilityGoodnessPct,
            totalGoodness, totalGoodnessPct,
            noiseGoodness, noiseGoodnessPct,
            correlationGoodness, correlationGoodnessPct);
    }

    //TODO:  this may be duplicated from TestUtils
    private FloatTimeSeries generateFloatTimeSeries(FsId id, int datai,
        boolean isEmpty, int startCadence, int endCadence) {
        final int nCadence = endCadence - startCadence + 1;
        boolean[] gaps = new boolean[nCadence];
        float[] data = new float[nCadence];
        if (isEmpty) {
            Arrays.fill(gaps, true);
        } else {
            gaps[0] = true;
            gaps[gaps.length - 1] = true;
            Arrays.fill(data, datai + 1);
        }

        return new FloatTimeSeries(id, data, startCadence, endCadence, gaps, 0,
            !isEmpty);
    }
}
