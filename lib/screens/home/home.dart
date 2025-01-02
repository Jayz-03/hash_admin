import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInventorySection(),
            _buildInfoCard(
              title: 'Hash Organization',
              content:
                  '''HASH is a non-profit, community-based organization committed to seeing that those affected by HIV have access to the care that they deserve. Established by Desi Andrew Ching and Michael De Guzman in 2015, HASH had humble beginnings in a shared office while developing and advocating for Community-Based Screening (“CBS”) and Community Case Management programs in the Philippines. Now one of the fastest-growing organizations in HIV awareness advocacy, HASH continues to bring innovations that hope to improve the sexual health and lives of Filipinos.''',
            ),
            _buildInfoCard(
              title: 'History',
              content:
                  '''HIV & AIDS Support House (HASH) was co-founded by two friends, Desi Andrew S. Ching and Michael P. De Guzman, who met as volunteers of a telephone counseling line on Human Immunodeficiency Virus and Acquired Immune Deficiency Syndrome (HIV and AIDS) in the mid-90s. By 2011, De Guzman had just returned to the country from more than 6 years of living in Cambodia while Ching had been living with HIV for about 4 years. The two agreed that something needed to be done to help improve the situation and promote the well-being of those newly diagnosed with HIV in order to positively affect treatment outcomes.''',
            ),
            _buildInfoCard(
              title: 'Flagship Programs',
              content:
                  '''● 1st to implement Community-based HIV Screening (CBS) in 2016
● Community case management (CCM, online and face-to-face)
● Training on CBS, CCM, Motivational interviewing, Intimate Partners violence
● Webinars on HIV, ART, SOGIE, HIV Policy Act, Mental Health
● 1st CSO to implement Pop-Out PrEP (community initiation/outside facility)
● 1st ever community-led (demedicalized) PrEP initiation in the Philippines
● Self test kits with more than 2,500 kits dispensed in 5 months''',
            ),
            _buildInfoCard(
              title: 'Achievements',
              content:
                  '''● Currently the convener of Network to Stop AIDS Philippines, and a member of Network Plus Phils. Inc.
● Seated as PLHIV CSO representative in the Quezon City STI/AIDS Council, and an active member of the Service Delivery Network of the cities of Pasay and Quezon City
● We have trained more than 1,400 CBS Motivators from 2016 to present
● We have helped more than 35,000 KP know their status since HASH was established.''',
            ),
            _buildSocialMediaHandles(),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySection() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .ref()
          .child('Inventory') // Firebase Database reference
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          // Parse data from Firebase snapshot
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // Extract specific inventory items
          final prepStocks = data['prep_medicine']['stocks'] ?? 'N/A';
          final testKitStocks = data['test_kits']['stocks'] ?? 'N/A';

          // Create the services list dynamically
          final List<Map<String, dynamic>> services = [
            {
              'imageUrl': 'assets/images/s1.png',
              'title': 'HIV Screening/Test',
              'description': 'This service is ONLY for old PrEP clients.',
              'stocks': testKitStocks,
            },
            {
              'imageUrl': 'assets/images/s2.png',
              'title': 'PrEP Refill',
              'description': 'New PrEP bottle service.',
              'stocks': prepStocks,
            },
            {
              'imageUrl': 'assets/images/s3.png',
              'title': 'PrEP: NEW CLIENT',
              'description':
                  'HIV, Hepatitis B, Syphilis test during appointment.',
              'stocks': prepStocks,
            },
          ];

          // Pass services to the UI builder
          return _buildServiceList(services);
        }

        // Show loading indicator while waiting for data
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildServiceList(List<Map<String, dynamic>> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: services.map((service) {
        final int stockCount = int.tryParse(service['stocks'].toString()) ?? 0;

        // Determine stock status and colors
        String stockStatus;
        Color stockColor;

        if (stockCount > 10) {
          stockStatus = "In Stock";
          stockColor = Colors.green;
        } else if (stockCount > 0) {
          stockStatus = "Low Stock";
          stockColor = Colors.orange;
        } else {
          stockStatus = "Out of Stock";
          stockColor = Colors.red;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
          child: Card(
            elevation: 4,
            color: Colors.white,
            child: ListTile(
              leading: service['imageUrl'] != null
                  ? Image.asset(
                      service['imageUrl']!,
                      width: 80,
                      height: 80,
                    )
                  : const SizedBox(width: 80, height: 80),
              title: Text(
                service['title'] ?? 'No Title',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 228, 142, 136),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service['description'] ?? 'No Description',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 125, 125, 125),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$stockStatus • ($stockCount)',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 14,
                      color: stockColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.robotoCondensed(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 240, 128, 128)),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.robotoCondensed(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaHandles() {
    final List<Map<String, dynamic>> socialMediaLinks = [
      {
        'icon': PhosphorIconsFill.facebookLogo,
        'url': 'https://www.facebook.com/HASHOrganization',
        'color': Colors.blue,
      },
      {
        'icon': PhosphorIconsFill.twitterLogo,
        'url': 'https://twitter.com/HASHOrganization',
        'color': Colors.lightBlue,
      },
    ];

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Follow Us On',
              style: GoogleFonts.robotoCondensed(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 240, 128, 128),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: socialMediaLinks.map((social) {
                return IconButton(
                  icon: Icon(social['icon']),
                  color: social['color'],
                  iconSize: 32,
                  onPressed: () {
                    _launchURL(social['url']);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
