module.exports = {
  purge: ['./src/**/*.js'],
  theme: {
    extend: {
      colors: {
        primaryBlue: '#006C9E',
        blue2: '#004A6E',
        blue3: '#E2EBF3',
        blue4: '#F3F8FA',
        gray1: '#333333',
        gray2: '#FAFAFA',
        gray3: '#828282',
        gray4: '#3B3B3B',
        gray5: '#E0E0E0',
        gray8: '#595959',
        gray9: '#262626',
        darkGray: '#676767',
        mediumGray: '#F2F2F2',
        lightGray: '#979797',
        white: '#FFFFFF',
        red1: '#D23C2A',
        red2: '#FFEDED',
        orange1: '#F8921F',
        orange2: '#FAE7D1',
        orange3: '#9C4814',
        green1: '#00853D',
        green2: '#DCFAEA',
        blueOverlay: '#004A6E80'
      },
      fontFamily: {
        'proxima-nova': ['Proxima Nova'],
        'proxima-nova-alt': ['Proxima Nova Alt']
      },
      fontSize: {
        twelve: '12px',
        fourteen: '14px',
        sixteen: '16px',
        eighteen: '18px',
        twenty: '20px',
        twentyFour: '24px',
        twentyEight: '28px',
        thirty: '30px',
        thirtySix: '36px',
        forty: '40px',
        fortyEight: '48px',
        sixtyFour: '64px',
        pointSevenFiveR: '.75rem',
        pointEightSevenFiveR: '.875rem',
        oneR: '1rem',
        onePointOneTwoFiveR: '1.125rem',
        onePointFiveR: '1.5rem',
        onePointSevenFiveR: '1.75rem',
        twoPointTwoFiveR: '2.25rem',
        twoPointFiveR: '2.5rem',
        threeR: '3rem'
      },
      fontWeight: {
        regular: '400',
        semiBold: '600',
        bold: '700'
      }
    },
    screens: {
      xs: '360px',
      sm: '768px',
      md: '1024px',
      lg: '1280px'
    },
    plugins: [require('./tailwind/plugins/base')()],
    future: {
      removeDeprecatedGapUtilities: true
    }
  }
}
