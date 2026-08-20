/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const CONNECTION_LOST_AFTER = 45000;

/**
 * How long the "server is restarting" banner stays up before it self-hides,
 * regardless of whether we ever get an explicit "we're back" signal from the
 * new session - the DM->JS handshake that would normally clear it can be lost
 * in transit during a reboot's reconnect window. This is a last-resort safety
 * net, not the primary fix - it should stay ABOVE the DM-side PANEL_INIT_MAX_RETRIES
 * auto-retry budget (currently ~2 minutes), so a genuinely still-broken panel
 * isn't masked by the banner clearing on a timer before the real handshake
 * actually recovers.
 */
export const ROUND_RESTART_BANNER_TIMEOUT = 150000;
