import { ZiggyVue } from 'ziggy';
import { route } from 'ziggy-js';

createInertiaApp({
    // ...
    setup({ el, App, props, plugin }) {
        createApp({ render: () => h(App, props) })
            .use(plugin)
            .use(ZiggyVue)        // ← добавить
            .mount(el);
    },
});