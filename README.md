### ShaderView

A minimally convenient way to apply a Metal Performance Shader to a UIView

The example UIViewController uses a the Gaussian Blur shader to animate (or not) blurring a UILabel.

Key Points:
 * Provide a source view to be Shadered
 * Provide an implementation of a callback that will be run with all the Metal Kit setup done for you during the draw call.
 * If you just want the shader performed once, don't pass an animation time into the `applyEffect` method
 * If not animated, the shader will be run any time the layout pass happens and the original view changes size. This will trigger the view's UIImage representation to be generated, so it's not the most efficient thing.
 * If animated, the shader will run on every frame during the animation time with the `progress` parameter being a unit value of the percentage complete.
 * The UIMPSView always sizes itself to it's SourceView and places the SourceView at the .zero origin.

After putting this repo up, I realized that the naming is rather problematic (one of the 2 hardest things in CS, amirite?), as it shouldn't have a `UI` prefix.

The class has been renamed to `ShaderView`, as, technically, you could do any shader or even drawing code, in the callback as you wish, tho it's really set up to be something to slap an MPS into. Although the repo and project name has remained.
