//
//  UIMPSView.swift
//  UIMPSView
//
//  Created by Alan Westbrook on 3/29/25.
//

import UIKit
import MetalKit
import MetalPerformanceShaders

class UIMPSView: MTKView {

  struct RenderParams {
    let commandBuffer: MTLCommandBuffer
    let destinationTexture: MTLTexture
    let device: MTLDevice
    let progress: Float?
    let sourceTexture: MTLTexture
    let view: UIMPSView
  }

  typealias RenderCallback = (RenderParams) -> Void

  private var animationDuration: TimeInterval?
  private var commandQueue: MTLCommandQueue?
  private var firstFrameCallback: (() -> Void)?
  private let renderCallback: RenderCallback
  private var sourceTexture: MTLTexture?
  private let sourceView: UIView
  private var startTime: CFTimeInterval = 0.0

  override var intrinsicContentSize: CGSize {
    sourceView.intrinsicContentSize
  }

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    sourceView.sizeThatFits(size)
  }

  init(
    sourceView: UIView,
    device: (any MTLDevice)? = nil,
    frame: CGRect = .zero,
    renderCallback: @escaping RenderCallback
  ) {
    self.sourceView = sourceView
    self.renderCallback = renderCallback

    super.init(frame: frame, device: device ?? MTLCreateSystemDefaultDevice())
    commandQueue = self.device?.makeCommandQueue()
    framebufferOnly = false
    isPaused = true
    addSubview(sourceView)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    sourceView.sizeToFit()
    frame.size = sourceView.bounds.size
    sourceView.frame = bounds
    updateContent()
  }

  override func draw(_ rect: CGRect) {
    guard let commandBuffer = commandQueue?.makeCommandBuffer(),
          let device,
          let sourceTexture,
          let destinationTexture = currentDrawable?.texture else {
      return
    }

    var progress: Float?
    if let animationDuration {
      let currentTime = CACurrentMediaTime() - startTime
      progress = Float(currentTime / animationDuration)
      if currentTime >= animationDuration {
        progress = 1.0
        isPaused = true
      }
    }

    renderCallback(
      RenderParams(
        commandBuffer: commandBuffer,
        destinationTexture: destinationTexture,
        device: device,
        progress: progress,
        sourceTexture: sourceTexture,
        view: self
      )
    )

    if let drawable = currentDrawable {
      commandBuffer.present(drawable)

      // Avoid an empty view when swapping from sourceView to texture
      if let firstFrameCallback {
        self.firstFrameCallback = nil
        commandBuffer.addCompletedHandler { _ in
          Task { @MainActor in
            firstFrameCallback()
          }
        }
      }
    }

    commandBuffer.commit()
  }

  private func updateContent() {
    // The sourceView has to have a render pass first lest the renderer fail
    DispatchQueue.main.async { [self] in
      sourceView.isHidden = false
      let image = UIGraphicsImageRenderer(bounds: sourceView.bounds).image { context in
        sourceView.drawHierarchy(in: bounds, afterScreenUpdates: false)
      }

      guard let device = device,
            let cgImage = image.cgImage else {
        print("Device or Image error")
        return
      }

      let textureLoader = MTKTextureLoader(device: device)
      do {
        sourceTexture = try textureLoader.newTexture(cgImage: cgImage)
      } catch {
        print("Failed to create texture from image: \(error)")
      }
    }
  }

  func applyEffect(withAnimationDuration duration: TimeInterval? = nil) {
    firstFrameCallback = { [self] in
      sourceView.isHidden = true
    }

    if let duration {
      animationDuration = duration
      startTime = CACurrentMediaTime()
      isPaused = false
    } else {
      setNeedsDisplay()
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
