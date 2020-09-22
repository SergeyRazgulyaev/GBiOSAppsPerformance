//
//  NewsForMe.swift
//  VKClient_RazgulyaevSergey
//
//  Created by Sergey Razgulyaev on 21.07.2020.
//  Copyright © 2020 Sergey Razgulyaev. All rights reserved.
//

import UIKit

struct NewsForMe {
    let newsForMeSender: String
    let newsForMeShortText: String
    var newsForMeImage: UIImage?
    var newsForMeAvatarImage: UIImage?
    init(newsForMeSender: String, newsForMeShortText: String, newsForMeImage: UIImage?, newsForMeAvatarImage: UIImage?) {
        self.newsForMeSender = newsForMeSender
        self.newsForMeShortText = newsForMeShortText
        self.newsForMeImage = newsForMeImage
        self.newsForMeAvatarImage = newsForMeAvatarImage
    }
}

var newsForMe: [NewsForMe] = [
    NewsForMe(newsForMeSender: "Kinopoisk.ru", newsForMeShortText: "Turtles attack in the cinema. Nickelodeon teamed up with production company Point Gray Pictures under the leadership of Seth Rogen to reboot the MCU Teenage Mutant Ninja Turtles. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse finibus nisi vel diam efficitur, vel volutpat justo congue. Vestibulum aliquam commodo massa non lobortis. Nullam ac consequat arcu. Curabitur sit amet libero porta lorem blandit sollicitudin. Phasellus at ipsum in ex tristique finibus sed quis orci. Pellentesque et tristique libero, quis euismod magna. Sed odio enim, laoreet vel bibendum non, placerat sed justo. Sed congue non purus sed rutrum. Mauris convallis nulla tellus, vel venenatis felis facilisis sed. Ut convallis sapien at lorem eleifend, sed ullamcorper massa consectetur. Etiam malesuada libero eu nulla sollicitudin venenatis. Proin lobortis nibh justo, sed imperdiet enim imperdiet fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Aliquam in felis leo. Nulla luctus tortor et diam egestas venenatis. Nullam venenatis augue sed metus laoreet convallis. Mauris et turpis metus. Pellentesque blandit sed dolor at euismod. Pellentesque nec efficitur nulla. Proin sed dolor a turpis tempor accumsan. Sed vel consequat lacus. Duis malesuada gravida nulla eu facilisis. ", newsForMeImage: UIImage(named: "TMNT"), newsForMeAvatarImage: UIImage(named: "kinopoisk")),
    NewsForMe(newsForMeSender: "IOS Dev", newsForMeShortText: "Apple is officially switching to native chips for some Macs. Calling it a historic day for the Mac, Apple CEO Tim Cook detailed the move to PowerPC, OS X 10 and the move to Intel chips, and then unveiled plans to use Apple's own ARM chip in the Mac in the future. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Praesent bibendum nisi sit amet est malesuada accumsan. Nulla facilisi. Interdum et malesuada fames ac ante ipsum primis in faucibus. Sed in laoreet purus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Mauris lobortis ultrices risus quis blandit. Phasellus quis posuere tortor, eu efficitur arcu. Phasellus tortor purus, pharetra tempus sem nec, ornare porttitor dolor. In at purus at tellus tempus cursus. Maecenas turpis eros, sagittis nec pulvinar commodo, pellentesque non tortor. In hac habitasse platea dictumst.", newsForMeImage: UIImage(named: "appleProcessor"), newsForMeAvatarImage: UIImage(named: "iOSDev")),
    NewsForMe(newsForMeSender: "Oil and Gas", newsForMeShortText: "Falling oil prices. From October 3 to November 29, oil quotations fell by more than a third - from $ 86.74 to $ 57.78 per barrel of Brent. Such sharp price reductions were observed only at the end of 2008 and in the fall of 2014. Etiam condimentum arcu lectus, nec auctor tortor interdum sit amet. Duis eros nunc, facilisis ac mi eu, rutrum molestie neque. Sed euismod nec ex nec mattis. Etiam imperdiet elit eget pretium egestas. Sed a risus condimentum, tincidunt neque id, hendrerit lectus. Vivamus rutrum leo sit amet felis sollicitudin tristique. Vivamus ut est sit amet quam laoreet consectetur in quis arcu. Aenean nec hendrerit neque, sed tristique ex. Praesent venenatis consectetur sagittis. Donec in orci magna. Proin at suscipit enim. Curabitur hendrerit lacinia venenatis. In maximus condimentum dapibus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis nec varius velit, eleifend commodo felis. Maecenas eleifend neque fringilla lobortis tempus.", newsForMeImage: UIImage(named: "oilPriceFalling"), newsForMeAvatarImage: UIImage(named: "oilAndGas"))
]
