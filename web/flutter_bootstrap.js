{{flutter_js}}
{{flutter_build_config}}

// Safe bootstrap for default JS builds and WebAssembly builds.
// Do not force `skwasm` here because official Flutter docs state that
// skwasm is only available for apps built with `--wasm`; default builds
// use CanvasKit. A forced skwasm selection on a non-wasm run can lead to
// a blank screen during startup.
const searchParams = new URLSearchParams(window.location.search);
const renderer = searchParams.get('renderer');

const userConfig = renderer ? { renderer } : {};

_flutter.loader.load({
  config: userConfig,
});
