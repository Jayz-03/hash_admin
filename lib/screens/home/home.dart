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
            Card(
              color: Colors.white,
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hash Organization',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 240, 128, 128)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '''HASH is a non-profit, community-based organization committed to seeing that those affected by HIV have access to the care that they deserve. Established by Desi Andrew Ching and Michael De Guzman in 2015, HASH had humble beginnings in a shared office while developing and advocating for Community-Based Screening (“CBS”) and Community Case Management programs in the Philippines. Now one of the fastest-growing organizations in HIV awareness advocacy, HASH continues to bring innovations that hope to improve the sexual health and lives of Filipinos.

HASH has many years of combined experience in the field of HIV and AIDS and offers inclusive screening, prevention, treatment, and education services. The organization is located in four different areas in Metro Manila and also has dedicated volunteers ready to help on the ground.''',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 240, 128, 128)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '''HIV & AIDS Support House (HASH) was co-founded by two friends, Desi Andrew S. Ching and Michael P. De Guzman, who met as volunteers of a telephone counseling line on Human Immunodeficiency Virus and Acquired Immune Deficiency Syndrome (HIV and AIDS) in the mid-90s. By 2011, De Guzman had just returned to the country from more than 6 years of living in Cambodia while Ching had been living with HIV for about 4 years. Ching had been keenly observing and taking note of his (and other Men having Sex with Men People Living with HIVs) experiences as clients of HIV-related health services. The two agreed that something needed to be done to help improve the situation and promote the well-being of those newly diagnosed with HIV in order to positively affect treatment outcomes.
              
In late 2013, the two did a series of consultation meetings with friends and colleagues working in the field of HIV & AIDS, and sexual health. They developed the yet unnamed organization’s concept paper. A Board of Trustees was convened months later, who helped in coming up with the name HASH. In late July, the Board, with the participation of some volunteers, conducted its first Strategic and Operational Planning Workshop and came up with the organization’s Vision and Mission, along with a 3-year Strategic and Operational Plan. The organization was registered with the Philippine Securities and Exchange Commission in 2015.''',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flagship Programs',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 240, 128, 128)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '''● 1st to implement Community-based HIV Screening (CBS) in 2016
● Community case management (CCM, online and face-to-face)
● Training on CBS, CCM, Motivational interviewing, Intimate Partners violence
● Webinars on HIV, ART, SOGIE, HIV Policy Act, Mental Health
● 1st CSO to implement Pop-Out PrEP (community initiation/outside facility)
● 1st ever community-led (demedicalized) PrEP initiation in the Philippines
● Self test kits with more than 2,500 kits dispensed in 5 months''',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 240, 128, 128)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '''● Currently the convener of Network to Stop AIDS Philippines, and a member of Network Plus Phils. Inc.
● Seated as PLHIV CSO representative in the Quezon City STI/AIDS Council, and an active member of the Service Delivery Network of the cities of Pasay and Quezon City
● We have trained more than 1,400 CBS Motivators from 2016 to present
● We have trained more than 500 Community Case Managers from 2016 to present
● We have helped more than 35,000 KP know their status since HASH was established.
● We have helped more than 3,000 people get on AntiRetroviral Treatment since 2016
● We have helped more than 3,000 people get on Pre-Exposure Prophylaxis from March 2021 to the present date.
● From March 04, 2021 - September 29, 2022, we were able to connect 27,220 people to the services they needed through our social media efforts.
● In 2023, we served more than 15,000 people online.
● We were able to establish a Trans Health and Literacy program, which touched the lives of 120 trans women
● HASH’s Community-Based HIV Screening program was awarded Project of the Year during the 2019 Ripple Awards hosted by LoveYourself
● HASH was awarded a Special Recognition for Case Finding and PrEP during the 2022 and 2023 Quilts Awards respectively, hosted by the EpIC Project.''',
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              child: Card(
                color: Colors.white,
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Social Media Handles',
                        style: GoogleFonts.robotoCondensed(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 240, 128, 128)),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchURL(
                                  'https://www.facebook.com/HASHPilipinas');
                            },
                            icon: PhosphorIcon(
                              PhosphorIconsFill.facebookLogo,
                              size: 30,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Facebook',
                              style: GoogleFonts.robotoCondensed(
                                  fontSize: 16, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 240, 128, 128),
                              textStyle: GoogleFonts.robotoCondensed(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 240, 128, 128)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchURL('https://twitter.com/HASH_Support');
                            },
                            icon: PhosphorIcon(
                              PhosphorIconsFill.twitterLogo,
                              size: 30,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Twitter',
                              style: GoogleFonts.robotoCondensed(
                                  fontSize: 16, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 240, 128, 128),
                              textStyle: GoogleFonts.robotoCondensed(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 240, 128, 128)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
