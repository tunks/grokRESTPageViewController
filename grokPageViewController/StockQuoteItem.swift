//
//  StockQuoteItems.swift
//  PullToUpdateDemo
//
//  Created by Christina Moulton on 2015-04-29.
//  Copyright (c) 2015 Teak Mobile Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

/* Feed of Apple, Yahoo & Google stock prices (ask, year high & year low) from Yahoo ( https://query.yahooapis.com/v1/public/yql?q=select%20symbol%2C%20Ask%2C%20YearHigh%2C%20YearLow%20from%20yahoo.finance.quotes%20where%20symbol%20in%20(%22AAPL%22%2C%20%22GOOG%22%2C%20%22YHOO%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys ) looks like
{
"query": {
"count": 3,
"created": "2015-04-29T16:21:42Z",
"lang": "en-us",
"results": {
"quote": [
{
"symbol": "AAPL"
"YearLow": "82.904",
"YearHigh": "134.540",
"Ask": "129.680"
},
...
]
}
}
}
*/
// See https://developer.yahoo.com/yql/ for tool to create queries

class StockQuoteItem: NSObject, NSCoding, ResponseJSONObjectSerializable {
  let symbol: String?
  let ask: String?
  let yearHigh: String?
  let yearLow: String?
  let timeSaved: NSDate?
  
  // MARK: Initializers
  required init(symbol: String?, ask: String?, yearHigh: String?, yearLow: String?, timeSaved: NSDate?) {
    self.symbol = symbol
    self.ask = ask
    self.yearHigh = yearHigh
    self.yearLow = yearLow
    self.timeSaved = timeSaved
  }
  
  required convenience init?(json: SwiftyJSON.JSON) {
    print(json)
    self.init(symbol: json["symbol"].string, ask: json["Ask"].string, yearHigh: json["YearHigh"].string, yearLow:json["YearLow"].string, timeSaved: NSDate())
  }
  
  // MARK: Web Service
  class func endpointForFeed(symbols: Array<String>) -> String {
    let symbolsString:String = symbols.joinWithSeparator("\", \"")
    let query = "select * from yahoo.finance.quotes where symbol in (\"\(symbolsString) \")&format=json&env=http://datatables.org/alltables.env"
    let encodedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
    
    let endpoint = "https://query.yahooapis.com/v1/public/yql?q=" + encodedQuery!
    return endpoint
  }
  
  class func getFeedItems(symbols: Array<String>, completionHandler: (Result<[StockQuoteItem]>) -> Void) {
    Alamofire.request(.GET, self.endpointForFeed(symbols))
      .responseArrayAtPath(["query", "results", "quote"], completionHandler:{ (request, response, result: Result<[StockQuoteItem]>) in
        completionHandler(result)
    })
  }
  
  // MARK: - NSCoding
  @objc func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(self.symbol, forKey: "symbol")
    aCoder.encodeObject(self.ask, forKey: "ask")
    aCoder.encodeObject(self.yearHigh, forKey: "yearHigh")
    aCoder.encodeObject(self.yearLow, forKey: "yearLow")
    aCoder.encodeObject(self.timeSaved, forKey: "timeSaved")
  }
  
  @objc required convenience init?(coder aDecoder: NSCoder) {
    let symbol = aDecoder.decodeObjectForKey("symbol") as? String
    let ask = aDecoder.decodeObjectForKey("ask") as? String
    let yearHigh = aDecoder.decodeObjectForKey("yearHigh") as? String
    let yearLow = aDecoder.decodeObjectForKey("yearLow") as? String
    let timeSaved = aDecoder.decodeObjectForKey("timeSaved") as? NSDate
    self.init(symbol: symbol, ask: ask, yearHigh: yearHigh, yearLow: yearLow, timeSaved: timeSaved)
  }
}
