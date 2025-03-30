### UIMPSView

A minimally convenient way to apply a Metal Performance Shader to a UIView

The example UIViewController uses a the Gaussian Blur shader to animate (or not) blurring a UILabel.

Key Points:
 * Provide a source view to be Shadered
 * Provide an implementation of a callback that will be run with all the Metal Kit setup done for you during the draw call.
 * If you just want the shader performed once, don't pass an animation time into the `applyEffect` method
 * The shader will be run any time the layout pass happens. A layout pass will also trigger the view's UIImage representation to be generated, so it's not the most efficient thing.
 * The UIMPSView always sizes itself to it's SourceView and places the SourceView at the .zero origin.
