import pluginJs from '@eslint/js'
import pluginVue from 'eslint-plugin-vue'

export default [
  pluginJs.configs.recommended,
  ...pluginVue.configs['flat/essential'],
  {
    rules: {
      'vue/no-unused-vars': 'warn',
      'no-undef': 0,
      // 'no-useless-assignment': 'warn',
      'no-use-before-define': 'error',
      'no-duplicate-imports': 'error',
      'arrow-body-style': ['error', 'as-needed'],
      'block-scoped-var': 'error',
      'default-param-last': 'warn',
      'func-style': ['warn', 'declaration'],
      'id-length': ['warn', { min: 2 }],
      'max-depth': ['warn', 4],
      'max-nested-callbacks': ['warn', 4],
      'max-params': ['warn', 4],
      'no-console': 'warn',
      'no-empty': 'error',
      'no-empty-function': 'error',
      'no-redeclare': 'warn',
      'no-var': 'error',
      'prefer-const': 'warn',
      'require-await': 'warn',
      'no-multi-spaces': 'warn',
      'vue/multi-word-component-names': 0,
      'vue/max-attributes-per-line': [
        'error',
        {
          singleline: {
            max: 4,
          },
          multiline: {
            max: 4,
          },
        },
      ],
      'vue/attribute-hyphenation': 0,
      'vue/html-self-closing': [
        'error',
        {
          html: {
            void: 'always',
            normal: 'always',
            component: 'always',
          },
          svg: 'always',
          math: 'always',
        },
      ],
      'vue/html-closing-bracket-spacing': 1,
      'vue/html-indent': 1,
      'block-spacing': 'error',
      'no-trailing-spaces': 'error',
      quotes: ['warn', 'single', { avoidEscape: true }],
      'no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0, maxBOF: 0 }],
      eqeqeq: ['error', 'smart'],
      camelcase: 'error',
      complexity: ['error', 15],
      // complexity: ['error', 3],
      curly: 'error',
      // 'sort-imports': ['error', {
      //   'ignoreCase': false,
      //   'ignoreDeclarationSort': false,
      //   'ignoreMemberSort': false,
      //   'memberSyntaxSortOrder': ['none', 'all', 'multiple', 'single'],
      //   'allowSeparatedGroups': true
      // }],
      indent: ['error', 2, { SwitchCase: 1 }],
    },
  },
]
