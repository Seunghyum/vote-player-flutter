import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vote_player_app/constants/gaps.dart';
import 'package:vote_player_app/constants/sizes.dart';
import 'package:vote_player_app/features/candidates/detail/widgets/bill_status_label.dart';
import 'package:vote_player_app/features/candidates/detail/widgets/bill_status_donut_chart.dart';
import 'package:vote_player_app/features/candidates/detail/widgets/list_table.dart';
import 'package:vote_player_app/models/candidate_model.dart';
import 'package:vote_player_app/utils/datetime.dart';
import 'package:vote_player_app/utils/url.dart';

class CandidateDetailScreen extends StatelessWidget {
  final String imagePath;
  final Candidate candidate;

  const CandidateDetailScreen({
    super.key,
    required this.imagePath,
    required this.candidate,
  });

  Future<void> _onLinkTap(String link) async {
    final Uri url = Uri.parse(getNormalizedUrl(link));
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  String renderEmptyString(String text) {
    return text.isNotEmpty ? text : '-';
  }

  int filterStatus(String status) {
    return candidate.bills.where((element) => element.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: Sizes.size24),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Hero(
                        tag: candidate.id,
                        child: CircleAvatar(
                          foregroundImage: NetworkImage(imagePath),
                        ),
                      ),
                    ),
                    Gaps.v10,
                    Text(
                      candidate.koName,
                      style: const TextStyle(
                        fontSize: Sizes.size20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.list(
              children: [
                Gaps.v10,
                ListTable(
                  data: [
                    {
                      "key": '소속 위원회',
                      "value": Text(
                        renderEmptyString(candidate.affiliatedCommittee),
                      ),
                    },
                    {
                      "key": '선거구',
                      "value": Text(
                        renderEmptyString(candidate.electoralDistrict),
                      ),
                    },
                    {
                      "key": '당선횟수',
                      "value": Text(
                        renderEmptyString(candidate.electionCount),
                      ),
                    },
                    {
                      "key": '의원 홈페이지',
                      "value": GestureDetector(
                        onTap: () => _onLinkTap(candidate.memberHomepage),
                        child: Text(
                          renderEmptyString(candidate.memberHomepage),
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    },
                    {
                      "key": '개별 홈페이지',
                      "value": GestureDetector(
                        onTap: () => _onLinkTap(candidate.individualHomepage),
                        child: Text(
                          renderEmptyString(candidate.individualHomepage),
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    }
                  ],
                ),
                Gaps.v24,
                const Text(
                  '대표 발의',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Sizes.size18,
                  ),
                ),
                const Divider(),
                BillStatusDonutChart(
                  passed: filterStatus('가결'),
                  pending: filterStatus('계류'),
                  amendmentPassed: filterStatus('수정안반영폐기'),
                  alternativePassed: filterStatus('대안반영폐기'),
                ),
                ...candidate.bills.map(
                  (e) => ListTile(
                    leading: BillStatusLabel(
                      status: e.status,
                    ),
                    title: FractionallySizedBox(
                      child: Text(
                        e.name,
                        style: const TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
                          fontSize: Sizes.size16,
                        ),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.committee),
                        Row(
                          children: [
                            Text(
                              e.nth,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            Text(' ${getyyyyMMdd(e.date)}~'),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_sharp,
                      size: Sizes.size32,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
