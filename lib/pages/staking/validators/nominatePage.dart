import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorDetailPage.dart';
import 'package:polkawallet_plugin_kusama/pages/staking/validators/validatorListFilter.dart';
import 'package:polkawallet_plugin_kusama/polkawallet_plugin_kusama.dart';
import 'package:polkawallet_plugin_kusama/store/staking/types/validatorData.dart';
import 'package:polkawallet_plugin_kusama/utils/format.dart';
import 'package:polkawallet_plugin_kusama/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class NominatePage extends StatefulWidget {
  NominatePage(this.plugin, this.keyring);
  static final String route = '/staking/nominate';
  final PluginKusama plugin;
  final Keyring keyring;
  @override
  _NominatePageState createState() => _NominatePageState();
}

class _NominatePageState extends State<NominatePage> {
  final List<ValidatorData> _selected = List<ValidatorData>();
  final List<ValidatorData> _notSelected = List<ValidatorData>();
  Map<String, bool> _selectedMap = Map<String, bool>();

  String _filter = '';
  int _sort = 0;

  TxConfirmParams _chill() {
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    return TxConfirmParams(
      txTitle: dicStaking['action.chill'],
      module: 'staking',
      call: 'chill',
      txDisplay: {'action': 'chill'},
      params: [],
    );
  }

  TxConfirmParams _setNominee() {
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final targets = _selected.map((i) => i.accountId).toList();
    return TxConfirmParams(
      txTitle: dicStaking['action.nominate'],
      module: 'staking',
      call: 'nominate',
      txDisplay: {'targets': targets.join(', ')},
      params: [targets],
    );
  }

  Widget _buildListItem(BuildContext context, ValidatorData validator) {
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');
    final int decimals = widget.plugin.networkState.tokenDecimals;
    final Map accInfo =
        widget.plugin.store.accounts.addressIndexMap[validator.accountId];
    final accIcon =
        widget.plugin.store.accounts.addressIconsMap[validator.accountId];
    final bool isWaiting = validator.total == BigInt.zero;
    final nominations =
        widget.plugin.store.staking.nominationsAll[validator.accountId] ?? [];
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        color: Theme.of(context).cardColor,
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 16),
              child: AddressIcon(validator.accountId, svg: accIcon),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UI.accountDisplayName(
                    validator.accountId,
                    accInfo,
                  ),
                  !isWaiting
                      ? Text(
                          '${dicStaking['total']}: ${Fmt.token(validator.total, decimals)}',
                          style: TextStyle(
                            color: Theme.of(context).unselectedWidgetColor,
                            fontSize: 12,
                          ),
                        )
                      : Container(),
                  Text(
                    isWaiting
                        ? dicStaking['waiting']
                        : '${dicStaking['commission']}: ${validator.commission}',
                    style: TextStyle(
                      color: Theme.of(context).unselectedWidgetColor,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isWaiting
                            ? '${dicStaking['nominators']}: ${nominations.length}'
                            : '${dicStaking['points']}: ${validator.points}',
                        style: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: _selectedMap[validator.accountId],
              onChanged: (bool value) {
                setState(() {
                  _selectedMap[validator.accountId] = value;
                });
                Timer(Duration(milliseconds: 300), () {
                  setState(() {
                    if (value) {
                      _selected.add(validator);
                      _notSelected.removeWhere(
                          (item) => item.accountId == validator.accountId);
                    } else {
                      _selected.removeWhere(
                          (item) => item.accountId == validator.accountId);
                      _notSelected.add(validator);
                    }
                  });
                });
              },
            ),
          ],
        ),
      ),
      onTap: () => Navigator.of(context)
          .pushNamed(ValidatorDetailPage.route, arguments: validator),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        widget.plugin.store.staking.validatorsAll.forEach((i) {
          _notSelected.add(i);
          _selectedMap[i.accountId] = false;
        });
        widget.plugin.store.staking.nominatingList.forEach((i) {
          _selected.add(i);
          _notSelected.removeWhere((item) => item.accountId == i.accountId);
          _selectedMap[i.accountId] = true;
        });

        // set recommended selected
        final List recommendList = widget
            .plugin.store.staking.recommendedValidators[widget.plugin.name];
        if (recommendList != null && recommendList.length > 0) {
          List<ValidatorData> recommended = _notSelected.toList();
          recommended
              .retainWhere((i) => recommendList.indexOf(i.accountId) > -1);
          recommended.forEach((i) {
            _selected.add(i);
            _notSelected.removeWhere((item) => item.accountId == i.accountId);
            _selectedMap[i.accountId] = true;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var dicStaking = I18n.of(context).getDic(i18n_full_dic_kusama, 'staking');

    List<ValidatorData> list = [];
    list.addAll(_selected);
    // add recommended
    final List recommendList =
        widget.plugin.store.staking.recommendedValidators[widget.plugin.name];
    if (recommendList != null && recommendList.length > 0) {
      List<ValidatorData> recommended = _notSelected.toList();
      recommended.retainWhere((i) => recommendList.indexOf(i.accountId) > -1);
      list.addAll(recommended);
    }

    // add validators
    // filter the _notSelected list
    List<ValidatorData> retained = List.of(_notSelected);
    retained = PluginFmt.filterValidatorList(
        retained, _filter, widget.plugin.store.accounts.addressIndexMap);
    // and sort it
    retained.sort((a, b) => PluginFmt.sortValidatorList(
        widget.plugin.store.accounts.addressIndexMap, a, b, _sort));
    list.addAll(retained);

    return Scaffold(
      appBar: AppBar(
        title: Text(dicStaking['action.nominate']),
        centerTitle: true,
      ),
      body: Builder(builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).cardColor,
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: ValidatorListFilter(
                  onFilterChange: (v) {
                    if (_filter != v) {
                      setState(() {
                        _filter = v;
                      });
                    }
                  },
                  onSortChange: (v) {
                    if (_sort != v) {
                      setState(() {
                        _sort = v;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int i) {
                    return _buildListItem(context, list[i]);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: TxButton(
                  getTxParams:
                      widget.plugin.store.staking.validatorsInfo.length == 0
                          ? () => null
                          : _selected.length == 0
                              ? _chill
                              : _setNominee,
                  onFinish: (bool success) {
                    if (success != null && success) {
                      Navigator.of(context).pop(success);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}