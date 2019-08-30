//
//  ViewController.swift
//  redso_test
//
//  Created by Joe Chen on 2019/8/28.
//  Copyright © 2019 Joe Chen. All rights reserved.
//

import UIKit
import CoreData

enum types {
    
    case Rangers
    case Elastic
    case Dynamo
    
    var string: String {
        
        switch self {
        case .Rangers:
            return "rangers"
        case .Elastic:
            return "elastic"
        case .Dynamo:
            return "dynamo"
        }
    }
    
    var upperCaseString : String{
        return string.capitalized
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    let moc = DetailsManageContext.shared()
    var refreshControl:UIRefreshControl!
    var currentTeam : types?
    var tempDetails : [details]!
    var currentPage : Int = 0
    var isUpdating : Bool = false
    var isNoDataFromAPI : Bool = false
    var isAppendData : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.getInfoDataFromAPI(team: types.Rangers.string, page: 0)
        self.currentTeam  = types.Rangers
        self.setRefreshControl()
        self.setSwiepGesture()
        
    }
    @IBAction func optionBtnClick(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        resetSetting()
        
        if btn.currentTitle == types.Rangers.upperCaseString, currentTeam != types.Rangers {
            getInfoDataFromAPI(team: types.Rangers.string, page: 0)
            currentTeam = types.Rangers
            
        }else if btn.currentTitle == types.Elastic.upperCaseString, currentTeam != types.Elastic {
            getInfoDataFromAPI(team: types.Elastic.string, page: 0)
            currentTeam = types.Elastic
            
        }else if btn.currentTitle == types.Dynamo.upperCaseString, currentTeam != types.Dynamo{
            getInfoDataFromAPI(team: types.Dynamo.string, page: 0)
            currentTeam = types.Dynamo
        }
    }
    
    func getInfoDataFromAPI(team : String, page : Int){
        
        guard isNoDataFromAPI == true else {
            RedClient.getinfoDetail(team: team, page: page) { (response, error) in
            
                if self.isUpdating == false, !(response?.results.isEmpty)!{
                    self.isUpdating = true
                    if self.currentPage == 0{
                        self.tempDetails = response?.results
                    }else{
                        self.tempDetails += response!.results
                    }
                    self.getCompleteDetails(team: team, page: page + 1)
                }
            
                if (response?.results.isEmpty)! {
                    self.isNoDataFromAPI = true
                }
            }
            return
        }
        
    }
    
    func getCompleteDetails(team :String ,page : Int){
        RedClient.getinfoDetail(team: team, page: page) { (response, error) in
            //            DetailModel.detailsInfo = response!.results
            self.tempDetails += response!.results
            DetailModel.detailsInfo = self.tempDetails
            self.currentPage = page
            self.isUpdating = false
            self.tableView.reloadData()
        }
    }
    
    
    func setRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.tableView.addSubview(refreshControl)
        self.refreshControl.addTarget(self, action: #selector(reloadTableViewData), for: UIControl.Event.valueChanged)
    }
    
    @objc func reloadTableViewData(){
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func setSwiepGesture(){
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(sender:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler(sender:)))
        swipeRight.direction = .right
        
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeRight)
        
    }
    
    @objc func swipeHandler(sender : UISwipeGestureRecognizer){
        
        var gotoType : types!
        if sender.direction == .left{
            if currentTeam == types.Rangers{
                gotoType = types.Elastic
            }else if currentTeam == types.Elastic{
                gotoType = types.Dynamo
            }
        }else{
            if currentTeam == types.Elastic{
                gotoType = types.Rangers
            }else if currentTeam == types.Dynamo{
                gotoType = types.Elastic
            }
        }
        currentTeam = gotoType
        resetSetting()
        getInfoDataFromAPI(team: gotoType.string, page: 0)
        
    }
    
    func resetSetting(){
        tempDetails.removeAll()
        isNoDataFromAPI = false
        isAppendData = false
    }
    
}

extension ViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DetailModel.detailsInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableCell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! detailTableViewCell
        tableCell.selectionStyle = UITableViewCell.SelectionStyle.none
        let info = DetailModel.detailsInfo[indexPath.row] as details

        tableCell.bannerImg.image  = nil
        tableCell.personImg.image  = nil
        if info.type == "banner"{
            tableCell.bannerImg.isHidden = false
            RedClient.downloadImage(imgUrl: info.url!) { (data, error) in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                tableCell.bannerImg?.image = image
                tableCell.setNeedsLayout()
            }
            
        }else{
            
            tableCell.nameLabel.text = info.name
            tableCell.positionLabel.text = info.position
            tableCell.skillLabel.text = info.expertise.map{$0}?.joined(separator:", ")
            RedClient.downloadImage(imgUrl: info.avatar!) { (data, error) in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                tableCell.personImg?.image = image
                tableCell.setNeedsLayout()
            }
        }
        
        return tableCell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if isNoDataFromAPI == false {
                if self.isUpdating == false{
                    currentPage = currentPage + 1
                    getInfoDataFromAPI(team: currentTeam!.string, page: currentPage)
                
                }
            }else{
                if isAppendData == false {
                    self.isAppendData = true
                    self.tempDetails += self.tempDetails
                    DetailModel.detailsInfo = self.tempDetails
                    self.tableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.isAppendData = false
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = .clear
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! optionCollectionViewCell
        
        if indexPath.row == 0 {
            collectionCell.optionBtn.setTitle(types.Rangers.upperCaseString, for: .normal)
        }else if indexPath.row == 1 {
            collectionCell.optionBtn.setTitle(types.Elastic.upperCaseString, for: .normal)
        }else{
            collectionCell.optionBtn.setTitle(types.Dynamo.upperCaseString, for: .normal)
        }
        
        return collectionCell
    }
    
    
}
