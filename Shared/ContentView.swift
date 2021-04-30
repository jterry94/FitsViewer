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
    
    let urlString = "https://fits.gsfc.nasa.gov/nrao_data/tests/ftt4b/file013.fits"
    let urlString2 = "https://fits.gsfc.nasa.gov/samples/UITfuv2582gc.fits"
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
    var threeData: ([FITSByte_F],vImage_Buffer,vImage_CGImageFormat)?
    func read(){
        var path = URL(string: path1)!
        var read_data = try! FitsFile.read(contentsOf: path)
        print(read_data)
    }
    var body: some View {
        HSplitView{
            Text("Hello, world!")
                .padding()
            
        }
        VStack{
            Button("Read", action: {self.read()})
                .padding()
        }

    }
    

}

