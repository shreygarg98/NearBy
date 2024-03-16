//
//  TableViewExtension.swift
//  NearBy
//
//  Created by Shrey Garg on 16/03/24.
//

import UIKit

extension UITableView{
    
    func registerTableCells(_ cells: UITableViewCell.Type...){
        cells.forEach { cellName in
            let identifier = String(describing: cellName.self)
            self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }
    
}
