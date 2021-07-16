import 'package:flutter/material.dart';

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const node_list_reef = [
  {
    'name': 'Reef Test Node1',
    'ss58': 42,
    'endpoint': 'wss://rpc-testnet.reefscan.com/ws',
  },
/*{
    'name': 'Kusama (Polkadot Canary, hosted by PatractLabs)',
    'ss58': 2,
    'endpoint': 'wss://kusama.elara.patract.io',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by Parity)',
    'ss58': 2,
    'endpoint': 'wss://kusama-rpc.polkadot.io/',
  },
  {
    'name': 'Kusama (Polkadot Canary, hosted by onfinality)',
    'ss58': 2,
    'endpoint': 'wss://kusama.api.onfinality.io/public-ws',
  },*/
];

const home_nav_items = ['staking', 'governance'];

const MaterialColor reef_purple = const MaterialColor(
  0xFF681cff,
  const <int, Color>{
    50: const Color(0xFFdacbf9),
    100: const Color(0xFFcab4f7),
    200: const Color(0xFFcab4f7),
    300: const Color(0xFFb798f7),
    400: const Color(0xFFb798f7),
    500: const Color(0xFF9565f7),
    600: const Color(0xFF7f46f4),
    700: const Color(0xFF7f46f4),
    800: const Color(0xFF5406f4),
    900: const Color(0xFF5406f4),
  },
);

const genesis_hash_reef =
    '0x0f89efd7bf650f2d521afef7456ed98dff138f54b5b7915cc9bce437ab728660'; // testnet
const String genesis_hash_kusama =
    '0xb0a8d493285c2df73290dfb7e61f870f17b41801197a149ca93654499ea3dafe';
const String genesis_hash_polkadot =
    '0x91b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3';
const String network_name_reef = 'reef';
const String network_name_kusama = 'kusama';
const String network_name_polkadot = 'polkadot';
