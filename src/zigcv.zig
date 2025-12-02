pub const asyncarray = @import("asyncarray.zig");
pub const core = @import("core.zig");
pub const calib3d = @import("calib3d.zig");
// pub const dnn = @import("dnn.zig");
pub const features2d = @import("features2d.zig");
pub const highgui = @import("highgui.zig");
pub const objdetect = @import("objdetect.zig");
pub const imgcodecs = @import("imgcodecs.zig");
pub const imgproc = @import("imgproc.zig");
pub const ColorConversionCode = @import("imgproc/color_codes.zig").ColorConversionCode;
pub const photo = @import("photo.zig");
pub const svd = @import("svd.zig");
pub const version = @import("version.zig");
pub const videoio = @import("videoio.zig");
pub const video = @import("video.zig");

pub const c = @import("c_api.zig").c;
pub const utils = @import("utils.zig");

test {
    _ = @import("asyncarray.zig");
    _ = @import("calib3d.zig");
    _ = @import("core.zig");
    _ = @import("core/mat.zig");
    _ = @import("core/mat_test.zig");
    // _ = @import("dnn.zig");
    _ = @import("dnn/test.zig");
    _ = @import("features2d.zig");
    _ = @import("highgui.zig");
    _ = @import("imgcodecs.zig");
    _ = @import("imgproc.zig");
    _ = @import("imgproc/test.zig");
    _ = @import("objdetect.zig");
    _ = @import("photo.zig");
    _ = @import("utils.zig");
    _ = @import("version.zig");
    _ = @import("video.zig");
    _ = @import("videoio.zig");
}
