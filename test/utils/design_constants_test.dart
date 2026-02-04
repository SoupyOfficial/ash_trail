import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/utils/design_constants.dart';

void main() {
  group('Spacing', () {
    test('xs has correct value', () {
      expect(Spacing.xs.value, 4);
    });

    test('sm has correct value', () {
      expect(Spacing.sm.value, 8);
    });

    test('md has correct value', () {
      expect(Spacing.md.value, 12);
    });

    test('lg has correct value', () {
      expect(Spacing.lg.value, 16);
    });

    test('xl has correct value', () {
      expect(Spacing.xl.value, 24);
    });

    test('xxl has correct value', () {
      expect(Spacing.xxl.value, 32);
    });

    test('xxxl has correct value', () {
      expect(Spacing.xxxl.value, 48);
    });
  });

  group('Paddings', () {
    test('none is zero', () {
      expect(Paddings.none, EdgeInsets.zero);
    });

    test('xs is 4 all sides', () {
      expect(Paddings.xs, const EdgeInsets.all(4));
    });

    test('sm is 8 all sides', () {
      expect(Paddings.sm, const EdgeInsets.all(8));
    });

    test('md is 12 all sides', () {
      expect(Paddings.md, const EdgeInsets.all(12));
    });

    test('lg is 16 all sides', () {
      expect(Paddings.lg, const EdgeInsets.all(16));
    });

    test('xl is 24 all sides', () {
      expect(Paddings.xl, const EdgeInsets.all(24));
    });

    test('xxl is 32 all sides', () {
      expect(Paddings.xxl, const EdgeInsets.all(32));
    });

    test('horizontalSm is 8 horizontal', () {
      expect(Paddings.horizontalSm, const EdgeInsets.symmetric(horizontal: 8));
    });

    test('horizontalMd is 12 horizontal', () {
      expect(Paddings.horizontalMd, const EdgeInsets.symmetric(horizontal: 12));
    });

    test('horizontalLg is 16 horizontal', () {
      expect(Paddings.horizontalLg, const EdgeInsets.symmetric(horizontal: 16));
    });

    test('horizontalXl is 24 horizontal', () {
      expect(Paddings.horizontalXl, const EdgeInsets.symmetric(horizontal: 24));
    });

    test('verticalSm is 8 vertical', () {
      expect(Paddings.verticalSm, const EdgeInsets.symmetric(vertical: 8));
    });

    test('verticalMd is 12 vertical', () {
      expect(Paddings.verticalMd, const EdgeInsets.symmetric(vertical: 12));
    });

    test('verticalLg is 16 vertical', () {
      expect(Paddings.verticalLg, const EdgeInsets.symmetric(vertical: 16));
    });

    test('verticalXl is 24 vertical', () {
      expect(Paddings.verticalXl, const EdgeInsets.symmetric(vertical: 24));
    });
  });

  group('IconSize', () {
    test('sm has correct value', () {
      expect(IconSize.sm.value, 16);
    });

    test('md has correct value', () {
      expect(IconSize.md.value, 24);
    });

    test('lg has correct value', () {
      expect(IconSize.lg.value, 28);
    });

    test('xl has correct value', () {
      expect(IconSize.xl.value, 48);
    });

    test('xxl has correct value', () {
      expect(IconSize.xxl.value, 64);
    });

    test('xxxl has correct value', () {
      expect(IconSize.xxxl.value, 80);
    });
  });

  group('BorderRadiusSize', () {
    test('sm has correct value', () {
      expect(BorderRadiusSize.sm.value, 8);
    });

    test('md has correct value', () {
      expect(BorderRadiusSize.md.value, 12);
    });

    test('lg has correct value', () {
      expect(BorderRadiusSize.lg.value, 16);
    });

    test('xl has correct value', () {
      expect(BorderRadiusSize.xl.value, 24);
    });

    test('borderRadius returns circular border', () {
      expect(BorderRadiusSize.md.borderRadius, BorderRadius.circular(12));
    });
  });

  group('BorderRadii', () {
    test('none is zero', () {
      expect(BorderRadii.none, BorderRadius.zero);
    });

    test('sm is 8', () {
      expect(BorderRadii.sm, const BorderRadius.all(Radius.circular(8)));
    });

    test('md is 12', () {
      expect(BorderRadii.md, const BorderRadius.all(Radius.circular(12)));
    });

    test('lg is 16', () {
      expect(BorderRadii.lg, const BorderRadius.all(Radius.circular(16)));
    });

    test('xl is 24', () {
      expect(BorderRadii.xl, const BorderRadius.all(Radius.circular(24)));
    });
  });

  group('ElevationLevel', () {
    test('none has correct value', () {
      expect(ElevationLevel.none.value, 0);
    });

    test('sm has correct value', () {
      expect(ElevationLevel.sm.value, 1);
    });

    test('md has correct value', () {
      expect(ElevationLevel.md.value, 2);
    });

    test('lg has correct value', () {
      expect(ElevationLevel.lg.value, 4);
    });

    test('xl has correct value', () {
      expect(ElevationLevel.xl.value, 8);
    });
  });

  group('DeviceFormFactor', () {
    test('fromWidth returns mobile for small width', () {
      expect(DeviceFormFactor.fromWidth(400), DeviceFormFactor.mobile);
    });

    test('fromWidth returns mobile for width just under tablet', () {
      expect(DeviceFormFactor.fromWidth(599), DeviceFormFactor.mobile);
    });

    test('fromWidth returns tablet for width at tablet breakpoint', () {
      expect(DeviceFormFactor.fromWidth(600), DeviceFormFactor.tablet);
    });

    test('fromWidth returns tablet for width between tablet and desktop', () {
      expect(DeviceFormFactor.fromWidth(900), DeviceFormFactor.tablet);
    });

    test('fromWidth returns tablet for width just under desktop', () {
      expect(DeviceFormFactor.fromWidth(1199), DeviceFormFactor.tablet);
    });

    test('fromWidth returns desktop for width at desktop breakpoint', () {
      expect(DeviceFormFactor.fromWidth(1200), DeviceFormFactor.desktop);
    });

    test('fromWidth returns desktop for large width', () {
      expect(DeviceFormFactor.fromWidth(1920), DeviceFormFactor.desktop);
    });
  });

  group('Breakpoints', () {
    test('mobileMaxWidth is 599', () {
      expect(Breakpoints.mobileMaxWidth, 599);
    });

    test('mobileSmallMaxWidth is 350', () {
      expect(Breakpoints.mobileSmallMaxWidth, 350);
    });

    test('mobileLargeMinWidth is 481', () {
      expect(Breakpoints.mobileLargeMinWidth, 481);
    });

    test('tabletBreakpoint is 600', () {
      expect(Breakpoints.tabletBreakpoint, 600);
    });

    test('tabletMaxWidth is 1199', () {
      expect(Breakpoints.tabletMaxWidth, 1199);
    });

    test('tabletLandscapeMinWidth is 800', () {
      expect(Breakpoints.tabletLandscapeMinWidth, 800);
    });

    test('desktopBreakpoint is 1200', () {
      expect(Breakpoints.desktopBreakpoint, 1200);
    });

    test('desktopMaxWidth is 1600', () {
      expect(Breakpoints.desktopMaxWidth, 1600);
    });

    test('wideDesktopMinWidth is 1920', () {
      expect(Breakpoints.wideDesktopMinWidth, 1920);
    });

    test('contentMaxWidth is 1200', () {
      expect(Breakpoints.contentMaxWidth, 1200);
    });
  });
}
