//
//  CustomMonthView.swift
//  CalendarReplica
//
//  Created by Anton Semenyuk on 10/23/18.
//  Copyright © 2018 Anton Semenyuk. All rights reserved.
//

import Foundation
import UIKit
import JZCalendarWeekView

class CustomWeekView: JZLongPressWeekView {
    var event: DefaultEvent!
    override func registerViewClasses() {
        super.registerViewClasses()
        
        self.collectionView.register(UINib(nibName: "EventCell", bundle: nil), forCellWithReuseIdentifier: "EventCell")
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.configureCell(event: getCurrentEvent(with: indexPath) as! DefaultEvent)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.configureCell(event: getCurrentEvent(with: indexPath) as! DefaultEvent)
        
        print(indexPath.row)
        print(cell.titleLabel.text!)
    }   
}


