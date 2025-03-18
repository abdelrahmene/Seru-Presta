import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Us',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(color: Colors.blueAccent, blurRadius: 5),
                Shadow(color: Colors.blueAccent, blurRadius: 10),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    'Our Mission',
                    'ASGSA is dedicated to providing high-quality maritime services and products to vessels worldwide. Our mission is to ensure the safety and efficiency of maritime operations through reliable products and exceptional service.',
                    Icons.sailing,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    'Our Services',
                    'We offer a comprehensive range of maritime services including ship supplies, spare parts, crew change management, and technical support. Our global network allows us to deliver services promptly wherever you need them.',
                    Icons.miscellaneous_services,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    'Our Team',
                    'Our team consists of experienced maritime professionals with decades of combined experience in the industry. We understand the challenges faced by vessel operators and are committed to providing solutions that meet your specific needs.',
                    Icons.people,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoSection(
                    'Contact Us',
                    'For inquiries and support, please contact us at:\nEmail: info@asgsa.com\nPhone: +123 456 7890\nAddress: 123 Maritime Street, Port City',
                    Icons.contact_mail,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}
