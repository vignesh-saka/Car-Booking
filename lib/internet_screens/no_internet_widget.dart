import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoInternetWidget extends StatefulWidget {
  final Future<void> Function() onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

  @override
  State<NoInternetWidget> createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget> {
  bool _isLoading = false;

  Future<void> _handleRetry() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    await widget.onRetry();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: height * 0.12,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            /// 🔄 Retry Button / Loader
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRetry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFFF4444),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Try Again',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
