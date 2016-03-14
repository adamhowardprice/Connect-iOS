import Foundation

typealias ChildControllerBuddySwapCompletionHandler = Void -> Void

protocol ChildControllerBuddy {
    func add(new: UIViewController, to parent: UIViewController, containIn: UIView) -> UIViewController
    func swap(old: UIViewController, new: UIViewController, parent: UIViewController) -> UIViewController
}

struct StockChildControllerBuddy: ChildControllerBuddy {
    func add(new: UIViewController, to parent: UIViewController, containIn containerView: UIView) -> UIViewController {
        if !parent.childViewControllers.contains(new) {
            parent.addChildViewController(new)
            containerView.addSubview(new.view)
            new.didMoveToParentViewController(parent)

            new.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view": new.view]))
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view": new.view]))
        }

        return new
    }

    func swap(old: UIViewController, new: UIViewController, parent: UIViewController) -> UIViewController {
        let containerView = old.view.superview!

        if old === new {
            return old
        }

        parent.addChildViewController(new)
        old.willMoveToParentViewController(nil)

        parent.transitionFromViewController(old, toViewController: new, duration: 0, options: .TransitionNone, animations: {}, completion: { completed in
            new.didMoveToParentViewController(parent)
            old.removeFromParentViewController()

            containerView.addSubview(new.view)

            new.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view": new.view]))
            containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view": new.view]))
        })

        return new
    }
}
