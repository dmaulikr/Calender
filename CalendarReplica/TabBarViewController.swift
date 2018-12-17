//
//  ViewController.swift
//  CalendarReplica
//
//  Created by Anton Semenyuk on 10/22/18.
//  Copyright © 2018 Anton Semenyuk. All rights reserved.
//

import UIKit

class TabBarViewController: UIViewController {

    var pageViewController: UIPageViewController!
    @IBOutlet weak var tabBar: UITabBar!
    var items = [UITabBarItem]()
    var dayView: CustomDayViewController!
    var weekView: WeekViewController!
    var monthView: MonthViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageViewController = self.children.last as! UIPageViewController
        self.findScrollView(self.pageViewController.view, enabled: false)
        dayView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomDayViewController") as? CustomDayViewController
        weekView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeekViewController") as? WeekViewController
        monthView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MonthViewController") as? MonthViewController
        self.pageViewController.setViewControllers([dayView], direction: .forward, animated: false, completion: nil)
        items.append(UITabBarItem(title: "Day View", image: UIImage(named: "day"), tag: 0))
        items.append(UITabBarItem(title: "Week View", image: UIImage(named: "week"), tag: 1))
        items.append(UITabBarItem(title: "Month View", image: UIImage(named: "month"), tag: 2))
        self.tabBar.delegate = self
        self.tabBar.setItems(items, animated: false)
        self.tabBar.selectedItem = items.first
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    @IBAction func onMonthClicked(_ sender: Any) {
        self.pageViewController.setViewControllers([monthView], direction: .forward, animated: false, completion: nil)
    }
    
    @IBAction func onWeekClicked(_ sender: Any) {
        self.pageViewController.setViewControllers([weekView], direction: .forward, animated: false, completion: nil)
    }
    
    @IBAction func onDayClicked(_ sender: Any) {
        self.pageViewController.setViewControllers([dayView], direction: .forward, animated: false, completion: nil)
    }
    
    
    func findScrollView(_ inView: UIView, enabled: Bool) {
        for view in inView.subviews {
            if view is UIScrollView {
                let scrollView = view as! UIScrollView
                scrollView.isScrollEnabled = enabled
            } else {
                print("UIScrollView does not exist on this View")
            }
        }
    }
}




extension TabBarViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 0 {
            self.pageViewController.setViewControllers([dayView], direction: .forward, animated: false, completion: nil)
        }
        if item.tag == 1 {
            self.pageViewController.setViewControllers([weekView], direction: .forward, animated: false, completion: nil)
        }
        if item.tag == 2 {
            self.pageViewController.setViewControllers([monthView], direction: .forward, animated: false, completion: nil)
        }
        
    }
}

