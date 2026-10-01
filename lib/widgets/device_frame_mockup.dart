import 'package:flutter/material.dart';
import 'package:device_frame/device_frame.dart';

class DeviceFrameMockup extends StatelessWidget {
  final Widget child;
  final double height;

  const DeviceFrameMockup({
    super.key,
    required this.child,
    this.height = 480,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: DeviceFrame(
          device: Devices.ios.iPhone13,
          isFrameVisible: true,
          orientation: Orientation.portrait,
          screen: Container(
            color: Colors.black,
            child: child,
          ),
        ),
      ),
    );
  }
}
