//
//  ContentView.swift
//  Shared
//
//  Created by anthony lim on 4/20/21.
//

import SwiftUI
import FITS
import FITSKit
import Accelerate
import Accelerate.vImage
import Combine

struct ContentView: View {
    @State private var selectNewImage = false
    

    
    var path = "file:///Users/anthonylim/Downloads/2020-12-03_19;56;17.fits"
    let path1 = "file:///Users/anthonylim/Downloads/2020-12-03_19;56;17.fits"
    let path2 = "file:///Users/anthonylim/Downloads/n5194.fits"
    let path3 = "file:///Users/anthonylim/Downloads/HIP115691-ID14333-OC148763-GR7975-LUM.fit"
    let path4 = "file:///Users/anthonylim/Downloads/JtIMAGE_009.fits"
    let path5 = "file:///Users/anthonylim/Downloads/2020-12-03_19_16_43.fits"
    let path6 = "file:///Users/anthonylim/Downloads/moon_BIN_1x1_0.0010s_002.fits"
    let path7 = "file:///Users/anthonylim/Downloads/NGC4438-104275-LUM.fit"
    let path8 = "file:///Users/anthonylim/Downloads/M66-ID10979-OC144423-GR4135-LUM2.fit"
    let path9 = "file:///Users/anthonylim/Downloads/NGC6960-ID14567-OC148925-GR8123-LUM.fit"
    var data = Data()
    func read() -> ([FITSByte_F],vImage_Buffer,vImage_CGImageFormat){
        var threeData: ([FITSByte_F],vImage_Buffer,vImage_CGImageFormat)?
        var path = URL(string: path7)!
        var read_data = try! FitsFile.read(contentsOf: path)
        let prime = read_data?.prime
        prime?.v_complete(onError: {_ in
            print("CGImage creation error")
        }) { result in
            threeData = result
        }
        return threeData!
    }
    func display() -> CGImage{
        let threedata = read()
        var data = threedata.0
        //target data
        var retdta = threedata.0
        //Buffer from FITS File
        var buffer = threedata.1
        //Grayscale format from FITS file
        let format = threedata.2
        //destination buffer
        var buffer2 = buffer
        var buffer4 = buffer

        var dataMin = data.min()// data type FITSByte_F
        var dataAvg = data.mean
        /*
        let kernel1D: [Float] = [0, 45, 136, 181, 136, 45, 0]
        var bendValue = Float(0.0)
        if dataAvg * 2.0 > 1.0 {
            bendValue = (1.0 - dataAvg)/2 + dataAvg
        }
        else
        {
            bendValue = 1.5 * dataAvg
        }
        for i in 0 ..< retdta.count{
            retdta[i] = (dataAvg * (retdta[i] / (data[i] + bendValue)) + 100.0 / 65535.0) * 10.0
        }
        let layerBytes = 510 * 510 * FITSByte_F.bytes
        let rowBytes = 510 * FITSByte_F.bytes
        
        var gray = retdta.withUnsafeMutableBytes{ mptr8 in
            vImage_Buffer(data: mptr8.baseAddress?.advanced(by: layerBytes * 0).bindMemory(to: FITSByte_F.self, capacity: 510 * 510), height: vImagePixelCount(510), width: vImagePixelCount(510), rowBytes: rowBytes)
        }
 */
        var dataMaxPixel = Pixel_F(data.max()!)
        var dataMinPixel = Pixel_F(data.min()!)
        var meanPixel = Pixel_F(data.mean)
        var stdevPixel = Pixel_F(data.stdev!)
        print("Pixel mean : ", meanPixel, "Pixel Stdev : ", stdevPixel)
        let histogramcount = 1024
        var histogramBin = [vImagePixelCount](repeating: 0, count: histogramcount)
        let histogramBinPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: histogramBin)
        histogramBin.withUnsafeMutableBufferPointer() { Ptr in
                            let error =
                                vImageHistogramCalculation_PlanarF(&buffer, histogramBinPtr, UInt32(histogramcount), dataMinPixel, dataMaxPixel, vImage_Flags(kvImageNoFlags))
                                guard error == kvImageNoError else {
                                fatalError("Error calculating histogram: \(error)")
                            }
                        }

    
        var histogram_optimized = histogramBin
        var histogramMean = histogramBin.mean
        var histogramStdev = histogramBin.stdev
        var histogramStdevp = histogramBin.stdevp
        var histogramAllcount = histogramBin.reduce(0,+)
        print("Mean : ", histogramMean, " Stdev : ", histogramStdev, " Stdevp : ", histogramStdevp, " Total : ", histogramAllcount)
        var histogramMedian = Double( histogramAllcount / 2)
        var meaningfulPixelvalue = 0
        var meaningfulPixelvalue2 = 0
        histogramBin[0] = 0
        for i in 0 ..< histogramcount{
            if histogramBin[i] < 5 {
                histogram_optimized[i] = 0
            }
            else{
                histogram_optimized[i] = histogram_optimized[i]
                meaningfulPixelvalue = i
            }
            
        }
        for i in 10 ..< histogramcount{
            if histogram_optimized[i] == 0{
                meaningfulPixelvalue2 = i
            }
            else{
                break
            }
        }
        print(histogram_optimized, meaningfulPixelvalue, meaningfulPixelvalue2)
        var upperPixelLimit = Pixel_F(Double(meaningfulPixelvalue) / Double(histogramcount))
        var lowerPixelLimt = Pixel_F(Double(meaningfulPixelvalue2) / Double(histogramcount))
        print("Lower Pixel Limit : ", lowerPixelLimt , " Upper Pixel Limit : ", upperPixelLimit)
        var optimized_histogram = histogramBin
        let optimized_histogramBinPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: optimized_histogram)
        histogramBin.withUnsafeMutableBufferPointer() { Ptr in
                            let error =
                                vImageHistogramCalculation_PlanarF(&buffer, optimized_histogramBinPtr, UInt32(histogramcount), lowerPixelLimt, upperPixelLimit, vImage_Flags(kvImageNoFlags))
                                guard error == kvImageNoError else {
                                fatalError("Error calculating histogram: \(error)")
                            }
                        }
        print(optimized_histogram)
        var histogramBin2 = [vImagePixelCount](repeating: 0, count: histogramcount)
        let histogramBinPtr2 = UnsafeMutablePointer<vImagePixelCount>(mutating: histogramBin2)
        histogramBin2.withUnsafeMutableBufferPointer() { Ptr in
                            let error =
                                vImageHistogramCalculation_PlanarF(&buffer4, histogramBinPtr2, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))
                                guard error == kvImageNoError else {
                                fatalError("Error calculating histogram: \(error)")
                            }
                        }
        print(histogramBin2)
        //vImageEndsInContrastStretch_PlanarF(&buffer, &buffer2, nil, 0, 50, histogramcount, 0.0, 0.1, vImage_Flags(kvImageNoFlags))
        vImageHistogramSpecification_PlanarF(&buffer, &buffer2, nil, optimized_histogram, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))
        //var buffer3 = buffer2
        //vImageEqualization_PlanarF(&buffer2, &buffer3, nil, histogramcount, lowerPixelLimt, upperPixelLimit, vImage_Flags(kvImageNoFlags))
        //vImageContrastStretch_PlanarF(&buffer2, &buffer3, nil, histogramcount, lowerPixelLimt, upperPixelLimit, vImage_Flags(kvImageNoFlags))
        let gamma: Float = 0.5
        let exponential:[Float] = [1, 0, 0]
    
        var buffer3 = buffer
        vImagePiecewiseGamma_PlanarF(&buffer2, &buffer3, exponential, gamma, [1,0], 0, vImage_Flags(kvImageNoFlags))
        var gammahistogram = [vImagePixelCount](repeating: 0, count: histogramcount)
        let gammahistogramPtr = UnsafeMutablePointer<vImagePixelCount>(mutating: gammahistogram)
        gammahistogram.withUnsafeMutableBufferPointer() { Ptr in
                            let error =
                                vImageHistogramCalculation_PlanarF(&buffer3, gammahistogramPtr, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))
                                guard error == kvImageNoError else {
                                fatalError("Error calculating histogram: \(error)")
                            }
                        }
        print(gammahistogram)
        vImageHistogramSpecification_PlanarF(&buffer, &buffer2, nil, gammahistogram, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))

        let result2 = (try? buffer2.createCGImage(format: format))!

        //let image = Image(result2!, scale: 1.0, label: Text("Image"))

        return result2
    }
    func changefile(){
        path == path2
        print(path)
    }

    var body: some View {
        HSplitView {
            VStack {
                Image(display(), scale: 1.0, label: Text("image"))
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(minWidth: 800, minHeight: 800)
            }
            
            VStack {
                Button("File", action: {self.changefile()})
            }
            .frame(minWidth: 400)
            .padding()
        }
                
        }

    }
    


