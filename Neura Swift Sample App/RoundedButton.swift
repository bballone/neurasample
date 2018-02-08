//
//  RoundedButton.swift
//  Push Notifications Test
//
//  Created by Neura on 10/13/16.
//  Copyright © 2016 Neura. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
  override func layoutSubviews() {
    super.layoutSubviews()
    self.layer.cornerRadius = self.bounds.size.height/2
  }
}
