//
//  ScrumVC.swift
//  scrum-master
//
//  Created by James B Morris on 5/22/18.
//  Copyright © 2018 James B Morris. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class GoalsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var goals: [Goal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
    }
    
    override func viewWillAppear (_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreDataObjects()
        tableView.reloadData()
    }
    
    func fetchCoreDataObjects() {
        self.fetch { (complete) in
            if complete {
                if goals.count >= 1 {
                    tableView.isHidden = false
                } else {
                    tableView.isHidden = true
                }
            }
        }
    }

    @IBAction func addGoalBtnWasPressed(_ sender: Any) {
        guard let createGoalVC = storyboard?.instantiateViewController(withIdentifier: "CreateGoalVC") else { return }
        presentDetail(createGoalVC)
    }
    
    @IBAction func clearBtnWasPressed(_ sender: Any) {
        guard goals.count > 0 else {
            return
        }
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        for goal in goals {
            managedContext.delete(goal)
        }
        do {
            try managedContext.save()
            print("Successfully removed goal!")
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
        }
        
        clear()
    }
    
    @objc private func clear(){
        var index = tableView.indexPathsForVisibleRows!.first!.row
        var blurs = [UIVisualEffectView]()
        var snap = [UIView]()
        while index < tableView.indexPathsForVisibleRows!.last!.row{
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            let snapshot = extractSnapshotFromView(originView: cell!)
            snapshot.center = cell!.center
            snapshot.alpha = 0
            tableView.addSubview(snapshot)
            let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blur.frame = CGRect(x: 0, y: 0, width: 1, height: snapshot.frame.height)
            snapshot.addSubview(blur)
            blurs.append(blur)
            snap.append(snapshot)
            index += 1
        }
        index = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
            guard index < blurs.count else {
                self.goals.removeAll()
                self.tableView.reloadData()
                timer.invalidate()
                return
            }
            let item = blurs[index]
            let snapshot = snap[index]
            snapshot.alpha = 1
            index += 1
            UIView.animate(withDuration: 1,delay: 0.25,options: .curveEaseIn,animations: {
                item.frame = CGRect(x: 0, y: 0, width: snapshot.frame.width, height:snapshot.frame.height)
            }, completion: { (success) in
                UIView.animate(withDuration: 1,delay: 0.25,options: .curveEaseIn, animations: {
                    snapshot.frame = CGRect(origin: CGPoint(x:snapshot.frame.origin.x,y:-100),size: snapshot.frame.size)
                }, completion: { (success) in
                    snapshot.removeFromSuperview()
                    self.tableView.isHidden = true
                })
            })
        }
        
    }
    
    private func extractSnapshotFromView(originView:UIView)->UIView {
        UIGraphicsBeginImageContextWithOptions(originView.bounds.size, false, 0)
        originView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapShotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: snapShotImage)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 5.0)
        snapshot.layer.shadowRadius = 5
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }


}

extension GoalsVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else { return UITableViewCell() }
        let goal = goals[indexPath.row]
        cell.configureCell(goal: goal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
            self.removeGoal(atIndexPath: indexPath)
            self.fetchCoreDataObjects()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let addAction = UITableViewRowAction(style: .normal, title: "ADD 1") { (rowAction, indexPath) in
            self.setProgress(atIndexPath: indexPath)
            tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
        addAction.backgroundColor = #colorLiteral(red: 0.9176470588, green: 0.662745098, blue: 0.2666666667, alpha: 1)
        deleteAction.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        return [deleteAction, addAction]
}
}

extension GoalsVC {
    func setProgress(atIndexPath indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let chosenGoal = goals[indexPath.row]
        
        if chosenGoal.goalProgress < chosenGoal.goalCompletionValue {
            chosenGoal.goalProgress = chosenGoal.goalProgress + 1
        } else {
            return
        }
        
        do {
            try managedContext.save()
            print("Successfully set progress!")
        } catch {
            debugPrint("Could not set progress: \(error.localizedDescription)")
        }
    }
    
    func removeGoal(atIndexPath indexPath: IndexPath) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        managedContext.delete(goals[indexPath.row])
        
        do {
            try managedContext.save()
            print("Successfully removed goal!")
        } catch {
            debugPrint("Could not remove: \(error.localizedDescription)")
        }
    }
    
    func fetch(completion: (_ complete: Bool) -> ()) {
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }
        
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        
        do {
            goals = try managedContext.fetch(fetchRequest)
            print("Successfully fetched data.")
            completion(true)
        } catch {
            debugPrint("Could not fetch: \(error.localizedDescription)")
            completion(false)
        }
    }
}
