<script setup>
import IconExternalLink from '../icons/IconExternalLink.vue'
import { useCopyFeedback } from '../../composables/useCopyFeedback'

const email = 'alexis.kessab@gmail.com'

const textGit = ' [ github       ]'
const textLink = ' [ linkedin    ]'

const { showFeedback, showHoverFeedback, hideFeedback } = useCopyFeedback()

async function copyEmail(event) {
  try {
    await navigator.clipboard.writeText(email)
  } catch {
    const input = document.createElement('input')
    input.value = email
    input.setAttribute('readonly', '')
    document.body.appendChild(input)
    input.select()
    document.execCommand('copy')
    document.body.removeChild(input)
  }
  showFeedback(event)
}
</script>

<template>
  <div class="contact">
    <p class="contact__statement">
      Currently looking for a
      <br />
      fulltime position as a front-end
      <br />
      developer in Paris or remote.
    </p>

    <div class="contact__details">
      <div class="contact__details-mail">
        <span>→ Reach out at</span>

        <div
          class="opacity hover"
          role="button"
          tabindex="0"
          @click="copyEmail($event)"
          @mouseenter="showHoverFeedback($event)"
          @mouseleave="hideFeedback()"
          @keydown.enter="copyEmail($event)"
          @keydown.space.prevent="copyEmail($event)"
        >
          <span> [ {{ email }}</span>

          <span class="bracket-close">
            <IconExternalLink />
            ]
          </span>
        </div>
      </div>

      <div class="contact__details-social">
        <span>→ Find me on</span>

        <div class="socials">
          <a class="opacity hover" href="https://github.com/lIlIllIIIIl" target="_blank">{{ textGit }}</a>
          <a class="opacity hover" href="https://www.linkedin.com/in/alexis-kessab-7bb710162/" target="_blank">{{ textLink }}</a>
        </div>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.contact {
  display: flex;
  flex-direction: column;
  gap: 3rem;
}

.contact__statement {
  font-family: "Geist";
  font-size: 1.35rem;
  font-weight: 400;
  line-height: 1.4;
  margin: 0;
}

.contact__details {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  font-family: "Geist";
  font-size: 0.88rem;

  &-mail {
    display: flex;
    flex-direction: row;
    gap: 2rem;
  }

  &-social {
    display: flex;
    flex-direction: row;
    gap: 2rem;
    white-space: pre;

    .socials {
        display: flex;
        flex-direction: column;

        a {
            text-decoration: none;
        }
    }
  }
}

.bracket-close {
    margin-left: 2rem;
}

.hover:hover {
    cursor: pointer;
    color: #ffffff;
    transition: color 0.2s ease;
}

</style>
