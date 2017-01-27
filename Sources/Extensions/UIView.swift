//
//  UIView.swift
//  ZamzamKit
//
//  Created by Basem Emara on 5/25/16.
//  Copyright © 2016 Zamzam. All rights reserved.
//

import Foundation

public extension UIView {

  var height: CGFloat {
    get { return frame.height }
    set { frame.size.height = newValue }
  }

  var width: CGFloat {
    get { return frame.width }
    set { frame.size.width = newValue }
  }

  var x: CGFloat {
    get { return frame.minX }
    set { frame.origin.x = newValue }
  }

  var y: CGFloat {
    get { return frame.minY }
    set { frame.origin.y = newValue }
  }
}
