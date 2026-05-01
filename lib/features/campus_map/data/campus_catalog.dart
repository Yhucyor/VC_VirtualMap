import 'package:flutter/material.dart';

import '../models/campus_place.dart';
import 'campus_places.dart';
import 'tdtu_campus_places.dart';

class CampusProfile {
  const CampusProfile({
    required this.id,
    required this.shortName,
    required this.fullName,
    required this.description,
    required this.photoCaption,
    required this.mapCaption,
    required this.color,
    required this.places,
    this.aliases = const [],
  });

  final String id;
  final String shortName;
  final String fullName;
  final String description;
  final String photoCaption;
  final String mapCaption;
  final Color color;
  final List<CampusPlace> places;
  final List<String> aliases;

  String get searchText {
    return '$shortName $fullName ${aliases.join(' ')}'.toLowerCase();
  }
}

const campusCatalog = <CampusProfile>[
  CampusProfile(
    id: 'hcmute',
    shortName: 'HCMUTE',
    fullName: 'ĐH Sư phạm Kỹ thuật TP.HCM',
    description:
        'Bản đồ tham quan, định vị khu học tập, hội trường, thư viện và các cổng chính.',
    photoCaption: 'Khu nhà trung tâm và các khối học tập HCMUTE.',
    mapCaption: 'Sơ đồ campus HCMUTE',
    color: Color(0xFF0B5DA8),
    aliases: ['su pham ky thuat', 'ute', 'spkt'],
    places: campusPlaces,
  ),
  CampusProfile(
    id: 'tdtu',
    shortName: 'TDTU',
    fullName: 'ĐH Tôn Đức Thắng',
    description:
        'Các điểm chính trong khuôn viên TDTU để tra cứu nhanh khi di chuyển.',
    photoCaption: 'Không gian học tập và khu sinh hoạt trong campus TDTU.',
    mapCaption: 'Sơ đồ campus TDTU',
    color: Color(0xFF155E75),
    aliases: ['ton duc thang'],
    places: tdtuCampusPlaces,
  ),
  CampusProfile(
    id: 'tdmu',
    shortName: 'TDMU',
    fullName: 'ĐH Thủ Dầu Một',
    description:
        'Bản đồ tổng thể campus, cổng vào, hội trường, thư viện và các dãy phòng học.',
    photoCaption: 'Ảnh minh họa khu nhà học và sân trung tâm ĐH Thủ Dầu Một.',
    mapCaption: 'Sơ đồ tổng thể Trường Đại học Thủ Dầu Một',
    color: Color(0xFF0284C7),
    aliases: ['thu dau mot', 'thủ dầu một'],
    places: tdmuCampusPlaces,
  ),
  CampusProfile(
    id: 'hcmut',
    shortName: 'HCMUT',
    fullName: 'ĐH Bách Khoa - ĐHQG-HCM',
    description:
        'Bản đồ mẫu cho khu giảng đường, thư viện, phòng thí nghiệm và khu hành chính.',
    photoCaption: 'Ảnh minh họa khối nhà chính ĐH Bách Khoa.',
    mapCaption: 'Sơ đồ campus ĐH Bách Khoa',
    color: Color(0xFF1D4ED8),
    aliases: ['bach khoa', 'bách khoa', 'bk', 'dai hoc bach khoa'],
    places: hcmutCampusPlaces,
  ),
  CampusProfile(
    id: 'vnu_hcm_us',
    shortName: 'VNUHCM-US',
    fullName: 'ĐH Khoa học Tự nhiên - ĐHQG-HCM',
    description:
        'Bản đồ mẫu cho khu giảng đường, thư viện, phòng thí nghiệm và khu dịch vụ sinh viên.',
    photoCaption: 'Ảnh minh họa khu giảng đường và phòng thí nghiệm.',
    mapCaption: 'Sơ đồ campus Khoa học Tự nhiên',
    color: Color(0xFF047857),
    aliases: ['khoa hoc tu nhien', 'khtn'],
    places: naturalScienceCampusPlaces,
  ),
  CampusProfile(
    id: 'ueh',
    shortName: 'UEH',
    fullName: 'ĐH Kinh tế TP.HCM',
    description:
        'Bản đồ mẫu hỗ trợ tìm khu học tập, hội trường, thư viện và văn phòng sinh viên.',
    photoCaption: 'Ảnh minh họa khu học tập và dịch vụ sinh viên UEH.',
    mapCaption: 'Sơ đồ campus UEH',
    color: Color(0xFF7C3AED),
    aliases: ['kinh te', 'kinh tế'],
    places: uehCampusPlaces,
  ),
  CampusProfile(
    id: 'hutech',
    shortName: 'HUTECH',
    fullName: 'ĐH Công nghệ TP.HCM',
    description:
        'Bản đồ mẫu cho các tòa nhà, thư viện, khu thực hành và điểm hỗ trợ sinh viên.',
    photoCaption: 'Ảnh minh họa khu thực hành và khối nhà học HUTECH.',
    mapCaption: 'Sơ đồ campus HUTECH',
    color: Color(0xFF0F766E),
    aliases: ['cong nghe', 'công nghệ'],
    places: hutechCampusPlaces,
  ),
];

const tdmuCampusPlaces = <CampusPlace>[
  CampusPlace(
    id: 'tdmu_gate_1',
    name: 'Cổng số 1',
    kind: 'Cổng vào/ra',
    area: 'Đường Trần Văn Ơn',
    description: 'Cổng chính để vào campus và khu hành chính.',
    landmark: 'Gần nhà bảo vệ và trục đường trung tâm.',
    mapPosition: Offset(0.82, 0.45),
    latitude: 10.98045,
    longitude: 106.67464,
    icon: Icons.flag,
    mapLabel: 'C1',
    routeSteps: [
      'Vào Cổng số 1.',
      'Đi theo trục đường trung tâm.',
      'Chọn điểm đến trên bản đồ.',
    ],
  ),
  CampusPlace(
    id: 'tdmu_library',
    name: 'Thư viện',
    kind: 'Học tập',
    area: 'Khu trung tâm',
    description: 'Khu đọc sách, tra cứu tài liệu và học nhóm.',
    landmark: 'Gần sân trung tâm và các dãy phòng học.',
    mapPosition: Offset(0.45, 0.44),
    latitude: 10.98062,
    longitude: 106.67412,
    icon: Icons.local_library,
    mapLabel: 'TV',
    routeSteps: [
      'Từ cổng chính đi thẳng vào sân trung tâm.',
      'Rẽ về khu thư viện.',
      'Thư viện nằm gần các dãy phòng học.',
    ],
  ),
  CampusPlace(
    id: 'tdmu_hall_1',
    name: 'Hội trường 1',
    kind: 'Hội trường',
    area: 'Cụm nhà học phía tây',
    description: 'Khu tổ chức hội thảo, sự kiện và sinh hoạt học thuật.',
    landmark: 'Gần dãy phòng học phía tây.',
    mapPosition: Offset(0.27, 0.42),
    latitude: 10.98050,
    longitude: 106.67378,
    icon: Icons.groups,
    mapLabel: 'HT1',
    routeSteps: [
      'Từ sân trung tâm rẽ trái.',
      'Đi theo dãy phòng học phía tây.',
      'Hội trường 1 nằm ở khối màu tím trên sơ đồ.',
    ],
  ),
  CampusPlace(
    id: 'tdmu_room_a101',
    name: 'Phòng A101',
    kind: 'Phòng học',
    area: 'Dãy A - tầng 1',
    description: 'Phòng học lý thuyết trong dãy A.',
    landmark: 'Gần lối vào dãy A và sân trung tâm.',
    mapPosition: Offset(0.38, 0.60),
    latitude: 10.98020,
    longitude: 106.67402,
    icon: Icons.meeting_room,
    mapLabel: 'A101',
    routeSteps: [
      'Đi từ sân trung tâm về dãy A.',
      'Vào tầng 1.',
      'Phòng A101 nằm gần đầu hành lang.',
    ],
  ),
];

const hcmutCampusPlaces = <CampusPlace>[
  CampusPlace(
    id: 'hcmut_gate',
    name: 'Cổng chính',
    kind: 'Cổng vào/ra',
    area: 'Đường Lý Thường Kiệt',
    description: 'Cổng chính vào khu nhà điều hành và các giảng đường.',
    landmark: 'Gần nhà bảo vệ và sân trước.',
    mapPosition: Offset(0.52, 0.92),
    latitude: 10.77210,
    longitude: 106.65785,
    icon: Icons.flag,
    mapLabel: 'C',
    routeSteps: [
      'Vào từ Cổng chính.',
      'Đi theo trục sân trước.',
      'Chọn khu cần đến trên bản đồ.',
    ],
  ),
  CampusPlace(
    id: 'hcmut_a4',
    name: 'Tòa A4',
    kind: 'Giảng đường',
    area: 'Khu giảng đường trung tâm',
    description: 'Tòa học lý thuyết và phòng học lớn.',
    landmark: 'Gần sân trung tâm và các dãy A.',
    mapPosition: Offset(0.46, 0.55),
    latitude: 10.77252,
    longitude: 106.65765,
    icon: Icons.apartment,
    mapLabel: 'A4',
    routeSteps: [
      'Từ cổng chính đi thẳng vào sân trung tâm.',
      'Rẽ trái theo dãy A.',
      'Tòa A4 nằm ở cụm giảng đường.',
    ],
  ),
  CampusPlace(
    id: 'hcmut_library',
    name: 'Thư viện',
    kind: 'Học tập',
    area: 'Khu trung tâm',
    description: 'Không gian học tập, đọc sách và tra cứu tài liệu.',
    landmark: 'Gần cụm giảng đường chính.',
    mapPosition: Offset(0.58, 0.38),
    latitude: 10.77286,
    longitude: 106.65795,
    icon: Icons.local_library,
    mapLabel: 'TV',
    routeSteps: [
      'Đi vào khu trung tâm.',
      'Qua dãy giảng đường.',
      'Thư viện nằm phía trên cụm A.',
    ],
  ),
  CampusPlace(
    id: 'hcmut_lab_c6',
    name: 'Phòng thí nghiệm C6',
    kind: 'Phòng thí nghiệm',
    area: 'Khu C',
    description: 'Khu thực hành và nghiên cứu chuyên ngành.',
    landmark: 'Gần dãy C và khu kỹ thuật.',
    mapPosition: Offset(0.72, 0.48),
    latitude: 10.77270,
    longitude: 106.65830,
    icon: Icons.science,
    mapLabel: 'C6',
    routeSteps: [
      'Từ sân trung tâm đi về dãy C.',
      'Theo hành lang kỹ thuật.',
      'Phòng C6 nằm trong khu lab.',
    ],
  ),
];

const naturalScienceCampusPlaces = <CampusPlace>[
  CampusPlace(
    id: 'us_gate',
    name: 'Cổng chính',
    kind: 'Cổng vào/ra',
    area: 'Trục vào campus',
    description: 'Điểm bắt đầu khi vào khuôn viên trường.',
    landmark: 'Gần khu bảo vệ và bảng chỉ dẫn tổng quan.',
    mapPosition: Offset(0.52, 0.94),
    latitude: 10.76262,
    longitude: 106.68222,
    icon: Icons.flag,
    mapLabel: 'C',
    routeSteps: [
      'Vào từ cổng chính.',
      'Đi theo trục đường trung tâm.',
      'Chọn điểm đến trên bản đồ.',
    ],
  ),
  CampusPlace(
    id: 'us_library',
    name: 'Thư viện',
    kind: 'Học tập',
    area: 'Khu trung tâm',
    description: 'Không gian học tập và tra cứu tài liệu.',
    landmark: 'Nằm gần cụm giảng đường chính.',
    mapPosition: Offset(0.50, 0.46),
    latitude: 10.76310,
    longitude: 106.68272,
    icon: Icons.local_library,
    mapLabel: 'L',
    routeSteps: [
      'Đi thẳng từ cổng chính.',
      'Qua khu giảng đường.',
      'Thư viện nằm ở khu trung tâm.',
    ],
  ),
  CampusPlace(
    id: 'us_lab',
    name: 'Khu phòng thí nghiệm',
    kind: 'Thực hành',
    area: 'Cụm khoa học ứng dụng',
    description: 'Khu thực hành, nghiên cứu và thí nghiệm.',
    landmark: 'Gần dãy phòng học chuyên ngành.',
    mapPosition: Offset(0.32, 0.58),
    latitude: 10.76300,
    longitude: 106.68185,
    icon: Icons.science,
    mapLabel: 'Lab',
    routeSteps: [
      'Từ thư viện rẽ trái.',
      'Đi qua khu giảng đường.',
      'Khu thí nghiệm nằm ở dãy bên trái.',
    ],
  ),
];

const uehCampusPlaces = <CampusPlace>[
  CampusPlace(
    id: 'ueh_hall',
    name: 'Hội trường',
    kind: 'Sự kiện',
    area: 'Khối nhà chính',
    description: 'Khu tổ chức hội thảo, sinh hoạt học thuật và sự kiện.',
    landmark: 'Gần sảnh chính và khu tiếp sinh viên.',
    mapPosition: Offset(0.52, 0.54),
    latitude: 10.75984,
    longitude: 106.68840,
    icon: Icons.groups,
    mapLabel: 'H',
    routeSteps: [
      'Vào sảnh chính.',
      'Đi theo bảng chỉ dẫn hội trường.',
      'Hội trường nằm trong khối nhà chính.',
    ],
  ),
  CampusPlace(
    id: 'ueh_library',
    name: 'Thư viện',
    kind: 'Học tập',
    area: 'Khu tự học',
    description: 'Khu đọc sách, học nhóm và tra cứu tài liệu.',
    landmark: 'Gần thang máy và khu tự học.',
    mapPosition: Offset(0.42, 0.36),
    latitude: 10.76012,
    longitude: 106.68868,
    icon: Icons.local_library,
    mapLabel: 'L',
    routeSteps: [
      'Từ sảnh chính đi lên khu tự học.',
      'Rẽ theo biển thư viện.',
      'Thư viện nằm gần khu học nhóm.',
    ],
  ),
  CampusPlace(
    id: 'ueh_student_service',
    name: 'Phòng hỗ trợ sinh viên',
    kind: 'Dịch vụ',
    area: 'Tầng thấp',
    description: 'Nơi hỗ trợ thủ tục, thông tin học vụ và dịch vụ sinh viên.',
    landmark: 'Gần khu tiếp nhận hồ sơ.',
    mapPosition: Offset(0.60, 0.76),
    latitude: 10.75955,
    longitude: 106.68832,
    icon: Icons.support_agent,
    mapLabel: 'SV',
    routeSteps: [
      'Vào sảnh chính.',
      'Đi tới khu tiếp nhận sinh viên.',
      'Phòng hỗ trợ nằm ở tầng thấp.',
    ],
  ),
];

const hutechCampusPlaces = <CampusPlace>[
  CampusPlace(
    id: 'hutech_gate',
    name: 'Cổng chính',
    kind: 'Cổng vào/ra',
    area: 'Mặt tiền campus',
    description: 'Điểm vào chính của campus.',
    landmark: 'Gần khu bảo vệ và sảnh đón.',
    mapPosition: Offset(0.50, 0.95),
    latitude: 10.80168,
    longitude: 106.71481,
    icon: Icons.flag,
    mapLabel: 'C',
    routeSteps: [
      'Vào cổng chính.',
      'Đi tới sảnh đón.',
      'Chọn khu cần đến trên bản đồ.',
    ],
  ),
  CampusPlace(
    id: 'hutech_practice',
    name: 'Khu thực hành',
    kind: 'Thực hành',
    area: 'Cụm phòng lab',
    description: 'Khu lab và phòng thực hành chuyên ngành.',
    landmark: 'Gần dãy phòng học kỹ thuật.',
    mapPosition: Offset(0.35, 0.58),
    latitude: 10.80210,
    longitude: 106.71452,
    icon: Icons.engineering,
    mapLabel: 'Lab',
    routeSteps: [
      'Từ cổng chính đi vào sảnh.',
      'Rẽ trái tới cụm phòng lab.',
      'Khu thực hành nằm bên trái campus.',
    ],
  ),
  CampusPlace(
    id: 'hutech_library',
    name: 'Thư viện',
    kind: 'Học tập',
    area: 'Khu trung tâm',
    description: 'Không gian học tập, đọc sách và học nhóm.',
    landmark: 'Gần khu tự học và thang máy.',
    mapPosition: Offset(0.56, 0.42),
    latitude: 10.80225,
    longitude: 106.71510,
    icon: Icons.local_library,
    mapLabel: 'L',
    routeSteps: [
      'Đi thẳng từ sảnh chính.',
      'Qua khu tự học.',
      'Thư viện nằm ở khu trung tâm.',
    ],
  ),
];
