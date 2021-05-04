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
import UniformTypeIdentifiers

struct ContentView: View {
    
    
    var path01 = "file:///Users/jterry/Downloads/M57v2_BIN_1x1_60s_001.fits"
    let path1 = "file:///Users/anthonylim/Downloads/2020-12-03_19;56;17.fits"
    let path2 = "file:///Users/jterry/Downloads/n5194.fits"
    let path3 = "file:///Users/anthonylim/Downloads/HIP115691-ID14333-OC148763-GR7975-LUM.fit"
    let path4 = "file:///Users/jterry/Downloads/JtIMAGE_009.fits"
    let path5 = "file:///Users/jterry/Downloads/2020-12-03_19_16_43.fits"
    let path6 = "file:///Users/jterry/Downloads/moon_BIN_1x1_0.0010s_002.fits"
    let path7 = "file:///Users/jterry/Downloads/NGC4438-104275-LUM.fit"
    let path8 = "file:///Users/anthonylim/Downloads/M66-ID10979-OC144423-GR4135-LUM2.fit"
    let path9 = "file:///Users/anthonylim/Downloads/NGC6960-ID14567-OC148925-GR8123-LUM.fit"
    let path0 = "file:///Users/jterry/Downloads/globular.fits"
  //  let path02 = "file:///Users/jterry/Downloads/m13_050414_14i14m_L.FIT"
    let path03 = "file:///Users/jterry/Downloads/HorseHead.fits"
    let path04 = "file:///Users/jterry/Downloads/m101_050511_12i60m_L.FIT"
    let path05 = "file:///Users/jterry/Downloads/m104_050406_12i60mF_L.FIT"
    let path06 = "file:///Users/jterry/Downloads/C2020Y3-ID14674-OC149038-GR8225-LUM.fit"
    let path07 = "file:///Users/jterry/Downloads/CRAB-NEBULA-ID09031-OC139256-GR9712-LUM2.fit"
    let path08 = "file:///Users/jterry/Downloads/ROSETTENEBULA-ID01992-OC106272-GR1166-LUM.fit"
    let path09 = "file:///Users/jterry/Downloads/NGC2438-104402-LUM.fit"
    let path10 = "file:///Users/jterry/Downloads/M66-ID10979-OC144423-GR4135-LUM2.fit"
    let path00 = "file:///Users/jterry/Downloads/ngc4038_050306_9i45mF_L.FIT"
    let path11 = "file:///Users/jterry/Downloads/NGC4569-ID14657-OC149080-GR8267-LUM.fit"
    let path12 = "file:///Users/jterry/Downloads/M5-ID14690-OC149088-GR8275-LUM.fit"
    let path13 = "file:///Users/jterry/Downloads/Calibrated-T11-dougggg-M101-20160316-034553-Luminance-BIN1-W-240-001.fit"
    let path14 = "file:///Users/jterry/Downloads/Calibrated-T16-dougggg-M33-20151110-233820-Luminance-BIN1-W-120-001.fit"
    let path15 = "file:///Users/jterry/Downloads/Calibrated-T21-dougggg-M51-20160403-020102-Luminance-BIN1-W-240-001.fit"
    

    let histogramcount = 1024
    
    @State var called = 0
    @State var isImporting: Bool = false
    @State var rawImage: Image?
    @State var processedImage: Image?
    @State var threedata: ([FITSByte_F],vImage_Buffer,vImage_CGImageFormat)?
    
    func read() -> ([FITSByte_F],vImage_Buffer,vImage_CGImageFormat){
        var threeData: ([FITSByte_F],vImage_Buffer,vImage_CGImageFormat)?
        var path = URL(string: path15)!
        var read_data = try! FitsFile.read(contentsOf: path)
        let prime = read_data?.prime
       // print(prime)
        prime?.v_complete(onError: {_ in
            print("CGImage creation error")
        }) { result in
            threeData = result
        }
        return threeData!
    }
    func read2() -> PrimaryHDU{
        var path = URL(string: path7)!
        var read_data = try! FitsFile.read(contentsOf: path)
        let prime = read_data!.prime
        return prime
    }
    func display() -> (CGImage, [vImagePixelCount]){
        //let threedata = read()
        var data = threedata!.0
        //target data
        var redta = threedata!.0
        //Buffer from FITS File
        var buffer = threedata!.1
        //Grayscale format from FITS file
        let format = threedata!.2
        let prime = read2()
        //destination buffer
        var buffer2 = buffer
        var buffer4 = buffer
        var buffer5 = buffer

        var dataMin = data.min()// data type FITSByte_F
        //var dataAvg = data.mean
        
        var dataMaxPixel = Pixel_F(data.max()!)
        var dataMinPixel = Pixel_F(data.min()!)
        var meanPixel = Pixel_F(data.mean)
        var stdevPixel = Pixel_F(data.stdev!)
        print("Pixel mean : ", meanPixel, "Pixel Stdev : ", stdevPixel)
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
        //print("Mean : ", histogramMean, " Stdev : ", histogramStdev, " Stdevp : ", histogramStdevp, " Total : ", histogramAllcount)
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
     //   print(histogram_optimized, meaningfulPixelvalue, meaningfulPixelvalue2)
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
        //print(optimized_histogram)
        var histogramBin2 = [vImagePixelCount](repeating: 0, count: histogramcount)
        let histogramBinPtr2 = UnsafeMutablePointer<vImagePixelCount>(mutating: histogramBin2)
        histogramBin2.withUnsafeMutableBufferPointer() { Ptr in
                            let error =
                                vImageHistogramCalculation_PlanarF(&buffer4, histogramBinPtr2, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))
                                guard error == kvImageNoError else {
                                fatalError("Error calculating histogram: \(error)")
                            }
                        }
       // print(histogramBin2)
        //vImageEndsInContrastStretch_PlanarF(&buffer, &buffer2, nil, 0, 50, histogramcount, 0.0, 0.1, vImage_Flags(kvImageNoFlags))
        vImageHistogramSpecification_PlanarF(&buffer, &buffer2, nil, optimized_histogram, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))
        //var buffer3 = buffer2
        //vImageEqualization_PlanarF(&buffer2, &buffer3, nil, histogramcount, lowerPixelLimt, upperPixelLimit, vImage_Flags(kvImageNoFlags))
        //vImageContrastStretch_PlanarF(&buffer2, &buffer3, nil, histogramcount, lowerPixelLimt, upperPixelLimit, vImage_Flags(kvImageNoFlags))
        let gamma: Float = 0.8
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
        //print(gammahistogram)
        vImageHistogramSpecification_PlanarF(&buffer, &buffer2, nil, gammahistogram, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))
        
        /*for i in 0 ..< kernel2D.count{
            kernel2D[i] = kernel2D[i] / kernel
        }*/
        let kernelwidth = 3
        let kernelheight = 3
        var kernelArray = [Float]()
        var A : Float = 1.0
        var simgaX: Float = 0.80
        var sigmaY: Float = 0.80
        //var Volume = 2.0 * Float.pi * A * simgaX * sigmaY
        for i in 0 ..< kernelwidth{
            let xposition = Float(i - kernelwidth / 2)
            for j in 0 ..< kernelheight{
            let yposition = Float(j - kernelheight / 2)
                var xponent = -xposition * xposition / (Float(2.0) * simgaX * simgaX)
                var yponent = -yposition * yposition / (Float(2.0) * sigmaY * sigmaY)
                let answer = A * exp (xponent + yponent)
                kernelArray.append(answer)
            }
        }
        var sum = kernelArray.reduce(0, +)
        for i in 0 ..< kernelArray.count{
            kernelArray[i] = kernelArray[i] / sum
        }
        print(kernelArray, " " , kernelArray.max())
       // print(buffer2)
       // print(buffer3)
        vImageConvolve_PlanarF(&buffer2, &buffer3, nil, 0, 0, &kernelArray, UInt32(kernelwidth), UInt32(kernelheight), 0, vImage_Flags(kvImageEdgeExtend))
        var histogramBin3 = [vImagePixelCount](repeating: 0, count: histogramcount)
        let histogramBinPtr3 = UnsafeMutablePointer<vImagePixelCount>(mutating: histogramBin3)
        histogramBin3.withUnsafeMutableBufferPointer() { Ptr in
                            let error =
                                vImageHistogramCalculation_PlanarF(&buffer, histogramBinPtr3, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))
                                guard error == kvImageNoError else {
                                fatalError("Error calculating histogram: \(error)")
                            }
                        }
        //print(histogramBin3)
        vImageHistogramSpecification_PlanarF(&buffer, &buffer2, nil, histogramBin3, UInt32(histogramcount), 0.0, 1.0, vImage_Flags(kvImageNoFlags))
        
        var imagePixelData = (buffer2.data.toArray(to: Float.self, capacity: Int(buffer2.width*buffer2.height)))
        
        var blurPixelData = (buffer3.data.toArray(to: Float.self, capacity: Int(buffer3.width*buffer3.height)))
        
        
        var myMin:Float = 0.0
        var blackLevel:Float = 0.0
        var minimumLevel:Float = imagePixelData.min()!
        
        if minimumLevel < 0.0 {minimumLevel = 0.0}
        
        if(minimumLevel > myMin.ulp  ){
        
            blackLevel = minimumLevel * 0.75
        }
        else{
            
            blackLevel = 0.0
        }
        
        for i in 0..<imagePixelData.count{
            
            imagePixelData[i] -= blackLevel
            
        }
        
        myMin = 0.0
        blackLevel = 0.0
        
        
        minimumLevel = blurPixelData.min()!
        
        if(minimumLevel > myMin.ulp  ){
        
            blackLevel = minimumLevel * 0.75
        }
        else{
            
            blackLevel = 0.0
        }
        
        
        for i in 0..<blurPixelData.count{
            
            blurPixelData[i] -= blackLevel
            
        }
        
        var average = blurPixelData.mean
        var bendValue :Float  = 0.0
        
        print("average blur = ", average)
        
       // if ((2*average) > 0.5 )
        if ((2*average) > 0.5 )
        {
            bendValue = (1.0 - average) / 2.0 + average
        }
        else
        {
            bendValue = 1.5 * average

        }
        
        print("bendValue =", bendValue)
        print("average = ", average)
        
       // let newBackgroundLevel :Float = 10.0/65535.0
        
        var newBackgroundLevel :Float = 0.0
        
        for i in 0..<imagePixelData.count{
            
            imagePixelData[i] = average * ((imagePixelData[i])/(blurPixelData[i] + bendValue)) + newBackgroundLevel
        }
        
        print(imagePixelData[76])
        
        average = imagePixelData.mean
        print("average = ", average)
        var maximum = imagePixelData.max()!
        var multiplier :Float = 1.0
        
        if (average < 0.5){
            multiplier = abs(0.5/average)
        }
        else{
        
            multiplier = abs(0.5*maximum/average)
            
        }
        
        
        print("muliplier = ", multiplier)
        
        for i in 0..<imagePixelData.count{
            
            imagePixelData[i] = multiplier * imagePixelData[i]
        }
        
        average = imagePixelData.mean
        
        newBackgroundLevel = average / 1.25
        
        for i in 0..<imagePixelData.count{
            
            imagePixelData[i] -= newBackgroundLevel
        }
        
        
        print("average =", average)
        
        
        let pixelDataAsData = Data(fromArray: imagePixelData)
        
        let cfdata = NSData(data: pixelDataAsData) as CFData
        
        let provider = CGDataProvider(data: cfdata)!
        
        let width :Int = Int(buffer2.width)
        let height: Int = Int(buffer2.height)
        let rowBytes :Int = width*4
        
        let bitmapInfo: CGBitmapInfo = [
            .byteOrder32Little,
            .floatComponents]
              
        let pixelCGImage = CGImage(width:  width, height: height, bitsPerComponent: 32, bitsPerPixel: 32, bytesPerRow: rowBytes, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: bitmapInfo, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
        


 //let result2 = (try? buffer2.createCGImage(format: format))!
        
        
        print("called")
        
        
        processedImage = Image(pixelCGImage!, scale: 3.5, label: Text("Image"))

        //return (result2, histogramBin2)
        
        return( pixelCGImage!, histogramBin2)
    }
    
    
    func displayRaw() -> (CGImage, [vImagePixelCount]){
      //  let threedata = read()
        var data = threedata!.0
        //target data
        var redta = threedata!.0
        //Buffer from FITS File
        var buffer = threedata!.1
        //Grayscale format from FITS file
        let format = threedata!.2
        let prime = read2()
        //destination buffer
        var buffer2 = buffer
        var buffer4 = buffer
        var buffer5 = buffer

        var dataMin = data.min()// data type FITSByte_F
        //var dataAvg = data.mean
        
        var dataMaxPixel = Pixel_F(data.max()!)
        var dataMinPixel = Pixel_F(data.min()!)
        var meanPixel = Pixel_F(data.mean)
        var stdevPixel = Pixel_F(data.stdev!)
        print("Pixel mean : ", meanPixel, "Pixel Stdev : ", stdevPixel)
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
        //print("Mean : ", histogramMean, " Stdev : ", histogramStdev, " Stdevp : ", histogramStdevp, " Total : ", histogramAllcount)
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
  /*      print(histogram_optimized, meaningfulPixelvalue, meaningfulPixelvalue2)
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
 
 */
        


 let result2 = (try? buffer.createCGImage(format: format))!
        
        
        print("called")
        
        

        
        rawImage = Image(result2, scale: 3.5, label: Text("Image"))

        return (result2, histogramBin)
        
        //return( pixelCGImage!, histogramBin2)
    }
    
    
    
    
    func histogram () -> [vImagePixelCount]{
        var originalhistogram = display().1
        return originalhistogram
    }

    var body: some View {
            VStack {
                ScrollView([.horizontal, .vertical]){
                   /* HSplitView{
                        Image(decorative: displayRaw().0, scale: 1.0)
                        //.resizable()
                        //.scaledToFit()
                        .padding()
                    }*/
                    rawImage
                    
                    
                }
                //.padding()
                ScrollView([.horizontal, .vertical]){
                    /*HSplitView{
                        Image(decorative: display().0, scale: 1.0)
                        //.resizable()
                        //.scaledToFit()
                        .padding()
                    }*/
                    processedImage
                }
                //.padding()
                VStack{
                    //Spacer()
                    Divider()
                    
                    Button("Load", action: {
                        isImporting = false
                        
                        //fix broken picker sheet
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isImporting = true
                        }
                    })
                        .padding()

                    /*Button("Invert", action: {histogram().self})
                    Button("Zero", action: {histogram().self})
                    Button("Reset", action: {histogram().self})*/
                }
            }
           // .padding()
            .fileImporter(
                isPresented: $isImporting,
                //allowedContentTypes: [UTType.plainText],
                allowedContentTypes: [.fitDocument],
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    
                    print("Selected file is", selectedFile)
                    
                    //trying to get access to url contents
                    if (CFURLStartAccessingSecurityScopedResource(selectedFile as CFURL)) {
                        
                        //guard let message = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                        
                        
                        
                        
                        guard let read_data = try! FitsFile.read(contentsOf: selectedFile) else { return }
                        let prime = read_data.prime
                        
                        prime.v_complete(onError: {_ in
                            print("CGImage creation error")
                        }) { result in
                            threedata = result
                            let _ = self.display()
                            let _ = self.displayRaw()
                        }
                        
                            
                        //done accessing the url
                        CFURLStopAccessingSecurityScopedResource(selectedFile as CFURL)
                        
                        
                    }
                    else {
                        print("Permission error!")
                    }
                } catch {
                    // Handle failure.
                    print(error.localizedDescription)
                }
            }

        }
    }

    


extension UnsafeMutableRawPointer {
    func toArray<T>(to type: T.Type, capacity count: Int) -> [T]{
        let pointer = bindMemory(to: type, capacity: count)
        return Array(UnsafeBufferPointer(start: pointer, count: count))
    }
}


extension Data {

    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }

    func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
        var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
        _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
        return array
    }
}


extension UTType {
  static let fitDocument = UTType(
    exportedAs: "com.jtIIT.fit")
}
