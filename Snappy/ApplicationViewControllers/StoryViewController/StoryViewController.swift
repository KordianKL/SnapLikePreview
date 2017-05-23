//
//  Created by Kordian Ledzion on 17.05.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import UIKit

class StoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var snaps = [Snap]()
    fileprivate let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadSnaps()
    }
    
    private func setupLayout(){
        tableView.register(UINib(nibName: "StoryCellTableViewCell", bundle: Bundle.main)
, forCellReuseIdentifier: "StoryCellTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(){
        downloadSnaps()
    }
    
    private func downloadSnaps(){
        snaps.removeAll()
        let endpoint = Endpoint.getPhotos(userId: nil)
        API.request(endpoint, completion: { [weak self] success, valueDictionary in
            guard let images = valueDictionary?["images"] as? [[String: Any]] else { return }
            images.forEach { image in
                guard let url = image["url"] as? String, let fileName = image["file_name"] as? String else { return }
                let snap = Snap(url: url, fileName: fileName)
                self?.snaps.append(snap)
            }
            
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        })
    }
}

extension StoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snaps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCellTableViewCell", for: indexPath) as! StoryCellTableViewCell
        cell.nameLabel.text = "Snap \(indexPath.row)"
        return cell
    }
}

extension StoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = SnapViewController(snap: snaps[indexPath.row])
        present(viewController, animated: true, completion: nil)
    }
}
