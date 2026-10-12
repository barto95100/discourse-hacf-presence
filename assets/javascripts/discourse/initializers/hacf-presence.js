import { apiInitializer } from "discourse/lib/api";
import HacfPresencePill from "../components/hacf-presence-pill";

export default apiInitializer((api) => {
  api.renderInOutlet("above-main-container", HacfPresencePill);
});
