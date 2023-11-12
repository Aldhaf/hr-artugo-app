import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  get dMMMy {
    var value = this;
    return DateFormat("d MMM y").format(value);
  }

  get dMMMykksss {
    var value = this;
    return DateFormat("d MMM y kk:mm").format(value);
  }

  get kkmmss {
    var value = this;
    return DateFormat("kk:mm:ss").format(value);
  }

  get dd {
    var value = this;
    return DateFormat("dd").format(value);
  }

  get MMM {
    var value = this;
    return DateFormat("MMM").format(value);
  }

  get y {
    var value = this;
    return DateFormat("y").format(value);
  }
}

extension DateStringExtension on String {
  get dMMMy {
    var value = this;
    return DateFormat("d MMM y").format(DateTime.parse(value));
  }

  get dMMMykksss {
    var value = this;
    return DateFormat("d MMM y kk:mm").format(DateTime.parse(value));
  }

  get kkmmss {
    var value = this;
    return DateFormat("kk:mm:ss").format(DateTime.parse(value));
  }
}
