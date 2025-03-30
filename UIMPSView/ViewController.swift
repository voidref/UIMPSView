//
//  ViewController.swift
//  UIMPSView
//
//  Created by Alan Westbrook on 3/29/25.
//

import UIKit
import MetalKit
import MetalPerformanceShaders

class ViewController: UIViewController {
  private var mpsView: UIMPSView?
  private var blurred = false
  private let blurSigma: Float = 40.0

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .black

    let label = UILabel()
    label.text = "Hello, World!"
    label.font = .systemFont(ofSize: 48, weight: .bold)
    label.textColor = .white
    label.sizeToFit()

    // Need extra space for the blur not to get clipped
    let inset = CGFloat(-blurSigma) / 2
    let sourceView = UIView(frame: label.frame.insetBy(dx: inset, dy: inset))
    sourceView.addSubview(label)
    label.frame.origin = CGPoint(x: -inset, y: -inset)

    // An example to blur in and out
    let mpsView = UIMPSView(sourceView: sourceView) { [weak self] params in
      guard let self else { return }
      let progress = params.progress ?? 1.0
      let blurFactor = blurred ? 1.0 - progress : progress
      let blurriness = blurFactor * blurSigma

      // Guassian Blur Metal Performace Shader!
      let blur = MPSImageGaussianBlur(device: params.device, sigma: blurriness)

      blur.encode(
        commandBuffer: params.commandBuffer,
        sourceTexture: params.sourceTexture,
        destinationTexture: params.destinationTexture
      )

      if blurFactor == 1.0 {
        blurred = true
      } else if blurFactor == 0.0 {
        blurred = false
      }
    }

    mpsView.sizeToFit()
    mpsView.layer.position = view.layer.position

    view.addSubview(mpsView)
    mpsView.isPaused = true
    mpsView.enableSetNeedsDisplay = true
    self.mpsView = mpsView

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    view.addGestureRecognizer(tapGesture)
  }

  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    mpsView?.applyEffect(withAnimationDuration: 2)
  }
}



