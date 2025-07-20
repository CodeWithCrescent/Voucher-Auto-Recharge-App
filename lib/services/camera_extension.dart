// import 'package:camera/camera.dart';

// extension CameraControllerExtension on CameraController {
//   Future<CameraImage?> getCameraImage(XFile file) async {
//     try {
//       return await file.readAsBytes().then((bytes) {
//         return CameraImage(
//           width: value.previewSize!.width.toInt(),
//           height: value.previewSize!.height.toInt(),
//           format: value.previewSize!.height.toInt() == 1080
//               ? ImageFormatGroup.yuv420
//               : ImageFormatGroup.bgra8888,
//           planes: [
//             Plane(
//               bytes: bytes,
//               bytesPerRow: value.previewSize!.width.toInt(),
//             ),
//           ],
//         );
//       });
//     } catch (e) {
//       return null;
//     }
//   }
// }