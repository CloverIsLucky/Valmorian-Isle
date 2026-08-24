/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { createLogger } from 'tgui/logging';
import { store } from '../events/store';
import { roundRestartedAtAtom } from '../game/atoms';
import { MAX_CONNECTIONS_STORED } from './constants';
import { type ConnectionRecord, connectionsMatch } from './helpers';

type Telemetry = {
  connections: ConnectionRecord[];
};

type TelemetryRequestPayload = {
  limits?: {
    connections: number;
  };
};

const logger = createLogger('telemetry');

let telemetry: Telemetry | null = null;
let wasRequestedWithPayload;

export function telemetryRequest(payload: TelemetryRequestPayload): void {
  // Defer telemetry request until we have the actual telemetry
  if (!telemetry) {
    logger.debug('deferred telemetry');
    wasRequestedWithPayload = payload;
    return;
  }

  logger.debug('sending telemetry');
  const limits = payload?.limits?.connections;
  // Trim connections according to the server limit
  const connections = telemetry.connections.slice(0, limits);
  Byond.sendMessage('telemetry', { connections });
}

export function testTelemetryCommand() {
  // DM only sends this once, at the end of tgui_panel/proc/initialize() -
  // which runs for every (re)connect, including a reboot reconnect that
  // reuses this same live JS session rather than reloading the page. So
  // receiving it at all is itself proof we're connected again; clear any
  // stale "server is restarting" notice from before this handshake even if
  // the 'ready' ack below gets skipped because telemetry was already loaded.
  store.set(roundRestartedAtAtom, null);
  setTimeout(() => {
    if (!telemetry) {
      Byond.sendMessage('ready');
    }
  }, 500);
}

type TelemetryUpdatePayload = {
  config: {
    client: ConnectionRecord;
  };
};

export async function handleTelemetryData(
  payload: TelemetryUpdatePayload,
): Promise<void> {
  // Extract client data
  const client = payload?.config?.client;
  if (!client) {
    logger.error('backend/update payload is missing client data!');
    return;
  }

  // This "update" reply only reaches us over a live connection - it's the
  // earliest proof we're back after a reconnect, well before the next ping
  // cycle. Clear any stale "server is restarting" notice left over from a
  // reboot that didn't force a full page reload.
  store.set(roundRestartedAtAtom, null);

  // Load telemetry
  if (!telemetry) {
    const stored = await storage.get('telemetry');
    telemetry = {
      connections: stored?.connections ?? [],
    };
    logger.debug('Retrieved telemetry from storage', telemetry);
  }

  // Append a connection record
  let telemetryMutated = false;

  const duplicateConnection = telemetry!.connections.find((conn) =>
    connectionsMatch(conn, client),
  );

  if (!duplicateConnection) {
    telemetryMutated = true;
    telemetry!.connections.unshift(client);
    if (telemetry!.connections.length > MAX_CONNECTIONS_STORED) {
      telemetry!.connections.pop();
    }
  }

  // Save telemetry
  if (telemetryMutated) {
    logger.debug('Saving telemetry to storage', telemetry);
    storage.set('telemetry', telemetry);
  }

  // Continue deferred telemetry requests
  if (wasRequestedWithPayload) {
    const deferred = wasRequestedWithPayload;
    wasRequestedWithPayload = null;
    telemetryRequest(deferred);
  }
}
