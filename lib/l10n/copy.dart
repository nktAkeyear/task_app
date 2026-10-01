import 'package:flutter/material.dart';

import '../app.dart';
import '../domain/models.dart';

class Copy {
  const Copy(this.code);

  final String code;

  static Copy of(BuildContext context) => Copy(RepoScope.of(context).language);

  String pick(String ja, String en, String ko) {
    return switch (code) {
      'en' => en,
      'ko' => ko,
      _ => ja,
    };
  }

  String get lists => pick('リスト', 'Lists', '목록');
  String get today => pick('今日', 'Today', '오늘');
  String get upcoming => pick('近日', 'Upcoming', '예정');
  String get calendar => pick('カレンダー', 'Calendar', '달력');
  String get completed => pick('完了', 'Completed', '완료');
  String get search => pick('検索', 'Search', '검색');
  String get tools => pick('ツール', 'Tools', '도구');
  String get settings => pick('設定', 'Settings', '설정');
  String get inbox => pick('受信箱', 'Inbox', '받은편지함');

  String listTitle(ListModel list) {
    if (list.isInbox || list.id == inboxId) {
      return inbox;
    }
    return list.name;
  }
  String get back => pick('戻る', 'Back', '뒤로');
  String get backToLists => pick('リストへ戻る', 'Back to lists', '목록으로');
  String get open => pick('開く', 'Open', '열기');
  String get close => pick('閉じる', 'Close', '닫기');
  String get cancel => pick('キャンセル', 'Cancel', '취소');
  String get save => pick('保存', 'Save', '저장');
  String get add => pick('追加', 'Add', '추가');
  String get delete => pick('削除', 'Delete', '삭제');
  String get undo => pick('元に戻す', 'Undo', '실행 취소');
  String get none => pick('なし', 'None', '없음');
  String get low => pick('低', 'Low', '낮음');
  String get mid => pick('中', 'Medium', '중간');
  String get high => pick('高', 'High', '높음');

  String board(TaskBoard board, {String? listName}) {
    return switch (board) {
      TaskBoard.inbox => inbox,
      TaskBoard.today => today,
      TaskBoard.upcoming => upcoming,
      TaskBoard.calendar => calendar,
      TaskBoard.completed => completed,
      TaskBoard.search => search,
      TaskBoard.settings => settings,
      TaskBoard.list => listName ?? lists,
    };
  }

  String empty(TaskBoard board, {String query = ''}) {
    if (query.trim().isNotEmpty) {
      return pick('一致するタスクはありません。', 'No matching tasks.', '일치하는 할 일이 없습니다.');
    }
    return switch (board) {
      TaskBoard.inbox => pick(
        '受信箱は空です。下の欄からタスクを追加できます。',
        'The inbox is empty. Add a task in the field below.',
        '받은편지함이 비어 있습니다. 아래 칸에서 할 일을 추가하세요.',
      ),
      TaskBoard.today => pick(
        '今日のタスクはありません。',
        'Nothing due today.',
        '오늘 할 일이 없습니다.',
      ),
      TaskBoard.upcoming => pick(
        '今後7日のタスクはありません。',
        'Nothing due in the next 7 days.',
        '앞으로 7일 동안 할 일이 없습니다.',
      ),
      TaskBoard.completed => pick(
        '完了したタスクはまだありません。',
        'No completed tasks yet.',
        '완료한 할 일이 아직 없습니다.',
      ),
      TaskBoard.calendar => pick(
        'この日のタスクはありません。',
        'Nothing due this day.',
        '이 날짜의 할 일이 없습니다.',
      ),
      TaskBoard.list => pick(
        'このリストは空です。下の欄から追加できます。',
        'This list is empty. Add a task below.',
        '이 목록은 비어 있습니다. 아래에서 추가하세요.',
      ),
      TaskBoard.search => pick(
        'タスク名やメモから探せます。',
        'Search titles and notes.',
        '제목과 메모에서 찾을 수 있습니다.',
      ),
      TaskBoard.settings => '',
    };
  }

  String priority(int priority) {
    return switch (priority) {
      1 => low,
      2 => mid,
      3 => high,
      _ => none,
    };
  }

  String recurrence(String recurrence) {
    return switch (recurrence) {
      'daily' => pick('毎日', 'Daily', '매일'),
      'weekly' => pick('毎週', 'Weekly', '매주'),
      'monthly' => pick('毎月', 'Monthly', '매월'),
      'weekdays' => pick('平日', 'Weekdays', '평일'),
      _ => none,
    };
  }

  String reminder(String reminder) {
    return switch (reminder) {
      'ontime' => pick('時刻どおり', 'On time', '정시'),
      '5m' => pick('5分前', '5 min before', '5분 전'),
      '15m' => pick('15分前', '15 min before', '15분 전'),
      '1h' => pick('1時間前', '1 hour before', '1시간 전'),
      '1d' => pick('1日前', '1 day before', '1일 전'),
      _ => none,
    };
  }

  String due(DateTime due, {required bool hasTime, required DateTime now}) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(due.year, due.month, due.day);
    final diff = day.difference(today).inDays;
    final date = switch (diff) {
      0 => this.today,
      1 => pick('明日', 'Tomorrow', '내일'),
      -1 => pick('昨日', 'Yesterday', '어제'),
      _ when due.year == now.year => pick(
        '${due.month}月${due.day}日(${_weekday(due)})',
        '${_enMonth(due.month)} ${due.day}',
        '${due.month}월 ${due.day}일 (${_weekday(due)})',
      ),
      _ => pick(
        '${due.year}年${due.month}月${due.day}日',
        '${_enMonth(due.month)} ${due.day}, ${due.year}',
        '${due.year}년 ${due.month}월 ${due.day}일',
      ),
    };
    if (!hasTime) {
      return date;
    }
    final hh = due.hour.toString().padLeft(2, '0');
    final mm = due.minute.toString().padLeft(2, '0');
    return '$date $hh:$mm';
  }

  String monthTitle(DateTime month) {
    return pick(
      '${month.year}年${month.month}月',
      '${_enMonth(month.month)} ${month.year}',
      '${month.year}년 ${month.month}월',
    );
  }

  List<String> get weekdays =>
      pick('月,火,水,木,金,土,日', 'Mo,Tu,We,Th,Fr,Sa,Su', '월,화,수,목,금,토,일').split(',');

  String _weekday(DateTime value) => weekdays[value.weekday - 1];

  String _enMonth(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }

  String reminderBanner(String title) =>
      pick('リマインダー: $title', 'Reminder: $title', '알림: $title');
  String get createTask => pick('タスクを作成', 'Create task', '할 일 만들기');
  String get taskName => pick('タスク名', 'Task name', '할 일 이름');
  String get notes => pick('メモ', 'Notes', '메모');
  String get dueLabel => pick('期限', 'Due', '기한');
  String get pickDate => pick('日付を選ぶ', 'Choose a date', '날짜 선택');
  String get pickTime => pick('時刻を選ぶ', 'Choose a time', '시간 선택');
  String get time => pick('時刻', 'Time', '시간');
  String get clearDue => pick('期限を消す', 'Clear due date', '기한 지우기');
  String get priorityLabel => pick('優先度', 'Priority', '우선순위');
  String get createAction => pick('作成する', 'Create', '만들기');
  String get titleRequired =>
      pick('タスク名を入力してください。', 'Enter a task name.', '할 일 이름을 입력하세요.');
  String get nameRequired =>
      pick('名前を入力してください。', 'Enter a name.', '이름을 입력하세요.');
  String get quickAddHint => pick(
    'タスクを追加（例: 資料を送る 明日 10時）',
    'Add a task (e.g. send the file tomorrow 10am)',
    '할 일 추가 (예: 자료 보내기 내일 10시)',
  );
  String get searchHint =>
      pick('タスク名とメモを検索', 'Search titles and notes', '제목과 메모 검색');
  String get clearSearch => pick('検索をクリア', 'Clear search', '검색 지우기');
  String get markDone => pick('完了にする', 'Mark done', '완료로 표시');
  String get markUndone => pick('未完了に戻す', 'Mark not done', '완료 취소');
  String get swipeDone => pick('完了', 'Done', '완료');
  String get detailEmpty => pick(
    'タスクを選ぶと、メモや期限を編集できます。',
    'Select a task to edit notes and the due date.',
    '할 일을 선택하면 메모와 기한을 편집할 수 있습니다.',
  );
  String get taskGone =>
      pick('このタスクは削除されました。', 'This task was deleted.', '이 할 일은 삭제되었습니다.');
  String get tags => pick('タグ', 'Tags', '태그');
  String get addTag => pick('タグを追加', 'Add tag', '태그 추가');
  String get tagName => pick('タグ名', 'Tag name', '태그 이름');
  String get tagRequired =>
      pick('タグ名を入力してください。', 'Enter a tag name.', '태그 이름을 입력하세요.');
  String get checklist => pick('チェックリスト', 'Checklist', '체크리스트');
  String get addItem => pick('項目を追加', 'Add item', '항목 추가');
  String get deleteItem => pick('項目を削除', 'Delete item', '항목 삭제');
  String get repeat => pick('繰り返し', 'Repeat', '반복');
  String get reminderLabel => pick('リマインダー', 'Reminder', '알림');
  String notifyAt(String when) =>
      pick('通知予定: $when', 'Notification: $when', '알림 예정: $when');
  String get deleteTask => pick('タスクを削除', 'Delete task', '할 일 삭제');
  String deleteTaskAsk(String title) =>
      pick('「$title」を削除します。', 'Delete “$title”.', '「$title」을(를) 삭제합니다.');
  String get detail => pick('詳細', 'Details', '자세히');
  String get prevMonth => pick('前の月', 'Previous month', '이전 달');
  String get nextMonth => pick('次の月', 'Next month', '다음 달');
  String get noUserLists =>
      pick('自分のリストはまだありません。', 'You have no lists yet.', '아직 목록이 없습니다.');
  String get archive => pick('アーカイブ', 'Archive', '보관');
  String get unarchive => pick('元に戻す', 'Restore', '복원');
  String get addList => pick('リストを追加', 'Add list', '목록 추가');
  String get createList => pick('リストを作成', 'Create list', '목록 만들기');
  String get rename => pick('名前を変更', 'Rename', '이름 바꾸기');
  String get changeColor => pick('色を変える', 'Change color', '색 바꾸기');
  String get unarchiveList => pick('アーカイブを解除', 'Unarchive', '보관 해제');
  String get listActions => pick('リストの操作', 'List actions', '목록 작업');
  String get name => pick('名前', 'Name', '이름');
  String get color => pick('色', 'Color', '색');
  String get deleteList => pick('リストを削除', 'Delete list', '목록 삭제');
  String deleteListAsk(String name) => pick(
    '「$name」を削除し、中のタスクは受信箱へ移します。',
    'Delete “$name” and move its tasks to the inbox.',
    '「$name」을(를) 삭제하고 할 일은 받은편지함으로 옮깁니다.',
  );
  String get pomodoro => pick('ポモドーロ', 'Pomodoro', '뽀모도로');
  String get matrix => pick('マトリックス', 'Matrix', '매트릭스');
  String get habits => pick('習慣', 'Habits', '습관');
  String get diary => pick('日記', 'Diary', '일기');
  String get pomodoroBlurb => pick(
    '25分の集中と5分の休憩',
    'Focus, then a short or long break',
    '집중 후 짧은 휴식 또는 긴 휴식',
  );
  String get matrixBlurb => pick(
    '重要と緊急でタスクを分ける',
    'Sort tasks by important and urgent',
    '중요와 긴급으로 할 일을 나눕니다',
  );
  String get habitsBlurb =>
      pick('今日のチェックと連続日数', 'Today’s check and your streak', '오늘의 체크와 연속 일수');
  String get diaryBlurb => pick('1日につき1件', 'One entry per day', '하루에 하나');
  String get searchBlurb => pick('タスク名とメモ', 'Titles and notes', '제목과 메모');
  String get focusPhase => pick('集中', 'Focus', '집중');
  String get shortBreak => pick('短い休憩', 'Short break', '짧은 휴식');
  String get longBreak => pick('長い休憩', 'Long break', '긴 휴식');
  String sessions(int count) => pick(
    '終えた集中 $count 回',
    'Finished focus sessions: $count',
    '끝낸 집중 $count회',
  );
  String get task => pick('タスク', 'Task', '할 일');
  String get noTask => pick('タスクを付けない', 'No task', '할 일 없음');
  String get start => pick('開始', 'Start', '시작');
  String get pause => pick('一時停止', 'Pause', '일시정지');
  String get reset => pick('リセット', 'Reset', '초기화');
  String get pomoHint => pick(
    '集中のあと短い休憩です。4回ごとに長い休憩になります。',
    'A short break follows focus. Every fourth session uses the long break.',
    '집중 뒤에는 짧은 휴식입니다. 4번마다 긴 휴식이 옵니다.',
  );
  String get placeTask => pick('タスクを置く', 'Place a task', '할 일 놓기');
  String get place => pick('置く', 'Place', '놓기');
  String get noOpenTasks =>
      pick('置ける未完了のタスクがありません。', 'No open tasks to place.', '놓을 미완료 할 일이 없습니다.');
  String get quadrantEmpty => pick(
    'この区分のタスクはありません。',
    'No tasks in this quadrant.',
    '이 구역에는 할 일이 없습니다.',
  );
  String get unplaced => pick('まだ置いていない', 'Not placed yet', '아직 놓지 않음');
  String get move => pick('移動', 'Move', '이동');
  String get removePlacement => pick('区分から外す', 'Remove from matrix', '구역에서 빼기');
  String quadrant(int index) {
    return switch (index) {
      0 => pick('重要かつ緊急', 'Important and urgent', '중요하고 긴급'),
      1 => pick('重要だが緊急ではない', 'Important, not urgent', '중요하지만 긴급하지 않음'),
      2 => pick('緊急だが重要ではない', 'Urgent, not important', '긴급하지만 중요하지 않음'),
      _ => pick('どちらでもない', 'Neither', '둘 다 아님'),
    };
  }

  String get newHabit => pick('新しい習慣', 'New habit', '새 습관');
  String get habitsEmpty =>
      pick('習慣はまだありません。', 'No habits yet.', '아직 습관이 없습니다.');
  String streak(int count) =>
      pick('連続 $count 日', 'Streak $count days', '연속 $count일');
  String get reminderOptional => pick('通知', 'Reminder', '알림');
  String get noReminder => pick('通知なし', 'No reminder', '알림 없음');
  String get archivedHabits => pick('アーカイブした習慣', 'Archived habits', '보관한 습관');
  String get diaryEmpty => pick(
    'この日の日記はまだありません。',
    'No diary entry for this day yet.',
    '이 날의 일기가 아직 없습니다.',
  );
  String get diaryHint => pick('今日のことを書く', 'Write about the day', '오늘을 적어 보세요');
  String diaryDate(DateTime day) => pick(
    '${day.year}年${day.month}月${day.day}日',
    '${_enMonth(day.month)} ${day.day}, ${day.year}',
    '${day.year}년 ${day.month}월 ${day.day}일',
  );
  String get savedLocally =>
      pick('この端末に保存します', 'Saved on this device', '이 기기에 저장됩니다');

  String get settingsLead => pick(
    'Tas はこの端末に保存します。同期先は空のままで使えます。',
    'Tas keeps data on this device. Leave the sync URL empty to stay offline.',
    'Tas는 이 기기에 저장합니다. 동기화 주소는 비워 두어도 됩니다.',
  );
  String get appearance => pick('外観', 'Appearance', '모양');
  String get system => pick('システム', 'System', '시스템');
  String get light => pick('ライト', 'Light', '라이트');
  String get dark => pick('ダーク', 'Dark', '다크');
  String get accent => pick('アクセント', 'Accent', '강조색');
  String get language => pick('言語', 'Language', '언어');
  String get homeTab => pick('起動時のタブ', 'Home tab', '시작 탭');
  String get thisDevice => pick('この端末', 'This device', '이 기기');
  String get deviceName => pick('端末名', 'Device name', '기기 이름');
  String get saveDevice => pick('端末名を保存', 'Save device name', '기기 이름 저장');
  String deviceId(String id) =>
      pick('端末 ID: $id', 'Device ID: $id', '기기 ID: $id');
  String get sync => pick('同期', 'Sync', '동기화');
  String get syncUrl => pick('同期サーバーの URL', 'Sync server URL', '동기화 서버 URL');
  String get saveUrl => pick('URL を保存', 'Save URL', 'URL 저장');
  String get clearUrl => pick('URL を消す', 'Clear URL', 'URL 지우기');
  String get syncNow => pick('今すぐ同期', 'Sync now', '지금 동기화');
  String pending(int count) =>
      pick('未送信の変更: $count', 'Unsent changes: $count', '보내지 않은 변경: $count건');
  String get backup => pick('バックアップ', 'Backup', '백업');
  String get exportFile => pick('ファイルに書き出す', 'Export file', '파일로 내보내기');
  String get exportDialog =>
      pick('バックアップを書き出す', 'Export backup', '백업 내보내기');
  String get copyJson => pick('JSON をコピー', 'Copy JSON', 'JSON 복사');
  String get importFile => pick('ファイルから読み込む', 'Import file', '파일에서 가져오기');
  String get importDialog =>
      pick('バックアップを読み込む', 'Import backup', '백업 가져오기');
  String get pasteJson => pick('JSON を貼り付け', 'Paste JSON', 'JSON 붙여넣기');
  String get keyboard => pick('キーボード', 'Keyboard', '키보드');
  String get shortcuts => pick(
    'Ctrl+N  タスクを追加\nCtrl+F  検索\nCtrl+Enter  完了にする\nJ / K  前後のタスク\nCtrl+1 から Ctrl+5  受信箱、今日、近日、カレンダー、完了',
    'Ctrl+N  New task\nCtrl+F  Search\nCtrl+Enter  Complete\nJ / K  Move selection\nCtrl+1 to Ctrl+5  Inbox, today, upcoming, calendar, completed',
    'Ctrl+N  할 일 추가\nCtrl+F  검색\nCtrl+Enter  완료\nJ / K  선택 이동\nCtrl+1–5  받은편지함, 오늘, 예정, 달력, 완료',
  );
  String versionLabel(String? version) => version == null
      ? pick('バージョン', 'Version', '버전')
      : pick('バージョン $version', 'Version $version', '버전 $version');
  String get checkUpdate => pick('更新を確認', 'Check for updates', '업데이트 확인');
  String get focusMinutes => pick('集中（分）', 'Focus (min)', '집중 (분)');
  String get shortMinutes => pick('短い休憩（分）', 'Short break (min)', '짧은 휴식 (분)');
  String get longMinutes => pick('長い休憩（分）', 'Long break (min)', '긴 휴식 (분)');
  String get exported =>
      pick('バックアップを書き出しました。', 'Backup exported.', '백업을 내보냈습니다.');
  String get exportFailed => pick(
    '書き出せませんでした。JSON のコピーを使ってください。',
    'Could not export. Copy the JSON instead.',
    '내보내지 못했습니다. JSON을 복사해 주세요.',
  );
  String get copied => pick('JSON をコピーしました。', 'JSON copied.', 'JSON을 복사했습니다.');
  String get imported =>
      pick('バックアップを読み込みました。', 'Backup imported.', '백업을 가져왔습니다.');
  String get importFailed => pick(
    '読み込めませんでした。ファイルの形式を確認してください。',
    'Could not import. Check the file.',
    '가져오지 못했습니다. 파일 형식을 확인하세요.',
  );
  String get pasteTitle => pick('JSON を読み込む', 'Import JSON', 'JSON 가져오기');
  String get pasteHint =>
      pick('書き出した JSON を貼り付け', 'Paste exported JSON', '내보낸 JSON을 붙여넣기');
  String get importAction => pick('読み込む', 'Import', '가져오기');
  String get backupFormat =>
      pick('バックアップの形式を確認してください。', 'Check the backup format.', '백업 형식을 확인하세요.');
  String get syncUrlError => pick(
    'http または https の URL を入力してください。',
    'Enter an http or https URL.',
    'http 또는 https URL을 입력하세요.',
  );
  String get syncLocal => pick(
    '同期先は未設定です。データはこの端末に保存されます。',
    'No sync server. Data stays on this device.',
    '동기화 서버가 없습니다. 데이터는 이 기기에 저장됩니다.',
  );
  String get syncOk => pick('同期しました', 'Synced', '동기화했습니다');
  String get syncFail => pick(
    '同期できませんでした。データはこの端末に残っています。',
    'Could not sync. Data is still on this device.',
    '동기화하지 못했습니다. 데이터는 이 기기에 남아 있습니다.',
  );
  String get missingTask =>
      pick('タスクが見つかりません', 'Task not found', '할 일을 찾을 수 없습니다');
  String get markedUndone => pick('未完了に戻しました', 'Marked not done', '완료를 취소했습니다');
  String get recurrenceAdvanced => pick(
    'この回を完了し、次の予定を作りました',
    'Completed this occurrence and scheduled the next one',
    '이번 회를 완료하고 다음 일정을 만들었습니다',
  );
  String get markedDone => pick('完了にしました', 'Marked done', '완료했습니다');
  String get deleted => pick('削除しました', 'Deleted', '삭제했습니다');
  String get listDeleted => pick(
    'リストを削除し、タスクを受信箱へ移しました。',
    'Deleted the list and moved its tasks to the inbox.',
    '목록을 삭제하고 할 일을 받은편지함으로 옮겼습니다.',
  );
  String get dataError =>
      pick('データを開けませんでした。', 'Could not open your data.', '데이터를 열 수 없습니다.');
  String get retry => pick(
    'アプリを再起動してもう一度試してください。',
    'Restart the app and try again.',
    '앱을 다시 시작한 뒤 다시 시도하세요.',
  );
  String get updateTitle => pick('更新があります', 'Update available', '업데이트가 있습니다');
  String updateBody(String version) => pick(
    'このバージョンは古くなっています（$version）。更新をダウンロードしますか？',
    'This version is out of date ($version). Download the update?',
    '이 버전은 오래되었습니다 ($version). 업데이트를 다운로드할까요?',
  );
  String get later => pick('あとで', 'Not now', '나중에');
  String get download => pick('ダウンロード', 'Download', '다운로드');
  String get downloading => pick('ダウンロードしています…', 'Downloading…', '다운로드하는 중…');
  String get upToDate =>
      pick('最新のバージョンです。', 'You are on the latest version.', '최신 버전입니다.');
  String get installBlocked => pick(
    'インストールの許可がないため、ダウンロードしたファイルを開けません。リリースページを開きますか？',
    'Install permission is missing, so the downloaded file cannot be opened. Open the release page?',
    '설치 권한이 없어 받은 파일을 열 수 없습니다. 릴리스 페이지를 열까요?',
  );
  String get openRelease =>
      pick('リリースページを開く', 'Open release page', '릴리스 페이지 열기');
  String get downloadFailed => pick(
    'ダウンロードできませんでした。リリースページを開きますか？',
    'The download failed. Open the release page?',
    '다운로드하지 못했습니다. 릴리스 페이지를 열까요?',
  );
  String accentName(int index) {
    return switch (index) {
      0 => pick('ティール', 'Teal', '청록'),
      1 => pick('青', 'Blue', '파랑'),
      2 => pick('琥珀', 'Amber', '호박'),
      3 => pick('ローズ', 'Rose', '장미'),
      _ => pick('紫', 'Violet', '보라'),
    };
  }
}
