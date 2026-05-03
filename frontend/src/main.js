import { createApp, h } from "vue";
import { createPinia } from "pinia";


import { createVuetify } from "vuetify";
import { aliases, fa } from "vuetify/iconsets/fa";


import * as components from "vuetify/components";


import * as directives from "vuetify/directives";


import "vuetify/styles";





import App from "./App.vue";
import router from "./router";
import "./ui/theme.css";
import { useAuthStore } from "./store/auth";
import { useClinicStore } from "./store/clinic";



const iconAliases = {
  checkboxOn: "check_box",
  checkboxOff: "check_box_outline_blank",
  checkboxIndeterminate: "indeterminate_check_box",
  radioOn: "radio_button_checked",
  radioOff: "radio_button_unchecked",
  delimiter: "circle",
  collapse: "expand_less",
  complete: "check",
  cancel: "cancel",
  close: "close",
  delete: "delete",
  clear: "close",
  success: "check_circle",
  info: "info",
  warning: "warning",
  error: "error",
  prev: "chevron_left",
  next: "chevron_right",
  first: "first_page",
  last: "last_page",
  dropdown: "arrow_drop_down",
  menu: "menu",
  subgroup: "arrow_drop_down",
  edit: "edit",
  ratingEmpty: "star",
  ratingFull: "star",
  ratingHalf: "star_half",
  loading: "autorenew",
  plus: "add",
  minus: "remove",
  sortAsc: "arrow_upward",
  sortDesc: "arrow_downward",
  expand: "expand_more"
  ,
  unfold: "unfold_more",
  file: "attach_file",
  calendar: "calendar_month",
  treeviewCollapse: "expand_more",
  treeviewExpand: "chevron_right",
  tableGroupCollapse: "expand_more",
  tableGroupExpand: "chevron_right",
  eyeDropper: "colorize",
  upload: "upload",
  color: "palette",
  command: "keyboard_command_key",
  ctrl: "keyboard_control_key",
  space: "space_bar",
  shift: "shift",
  alt: "alt_key",
  enter: "keyboard_return",
  arrowup: "arrow_upward",
  arrowdown: "arrow_downward",
  arrowleft: "arrow_back",
  arrowright: "arrow_forward",
  backspace: "backspace",
  play: "play_arrow",
  pause: "pause",
  fullscreen: "fullscreen",
  fullscreenExit: "fullscreen_exit",
  volumeHigh: "volume_up",
  volumeMedium: "volume_down",
  volumeLow: "volume_mute",
  volumeOff: "volume_off",
  search: "search"
};

const vuetify = createVuetify({
  components,
  directives,
  icons: {
    defaultSet: "fa",
    aliases: iconAliases,
    sets: {
      fa
    }
  },
  theme: {
    defaultTheme: "clinicsLight",


    themes: {


      clinicsLight: {


        dark: false,


        colors: {


          primary: "#1B5E5B",


          secondary: "#5E7C78",


          accent: "#C3A35C",


          background: "#F5F3EE",


          surface: "#FFFFFF",


          error: "#B42318",


          info: "#1B5E5B",


          success: "#11765B",


          warning: "#B7791F"


        }


      }


    }


  }


});





const pinia = createPinia();
const app = createApp(App);

app.use(pinia);
app.use(router);
app.use(vuetify);

const auth = useAuthStore(pinia);
const clinic = useClinicStore(pinia);
const bootstrap = async () => {
  await clinic.loadClinic().catch(() => {});
  if (auth.token && !auth.user) {
    await auth.loadCurrentUser().catch(() => {});
  }
  app.mount("#app");
};

bootstrap().catch(() => {
  app.mount("#app");
});




