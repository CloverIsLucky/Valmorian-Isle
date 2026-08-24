import { store } from '../events/store';
import { roundRestartedAtAtom } from '../game/atoms';
import { lastPingedAtAtom } from './atoms';
import { pingSuccess, pings, sendPing } from './helpers';

type SoftPingPayload = {
  afk: boolean;
};

/**
 * Soft ping from the server.
 * It's intended to send periodic server-side metadata about the client,
 * e.g. its AFK status.
 */
export function pingSoft(payload: SoftPingPayload): void {
  const { afk } = payload;
  store.set(lastPingedAtAtom, Date.now());
  // A ping only reaches us over a live connection, so receiving one proves
  // we're back - clear any stale "server is restarting" notice left over
  // from a reboot that didn't force a full page reload.
  store.set(roundRestartedAtAtom, null);
  // On each soft ping where client is not flagged as afk,
  // initiate a new ping.
  if (!afk) {
    sendPing();
  }
}

type ReplyPingPayload = {
  index: number;
};

export function pingReply(payload: ReplyPingPayload) {
  const { index } = payload;

  const ping = pings[index];
  if (!ping) return; // This ping was already marked as failed due to timeout.

  pings[index] = null;
  const roundtrip = (Date.now() - ping.sentAt) * 0.5;

  pingSuccess(roundtrip);
}
