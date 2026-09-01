import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/core/widgets/delete-icon.dart';
import 'package:pos/core/widgets/left-green-bar.dart';
import 'package:pos/features/leave/domain/entites/leave.dart';
import 'package:pos/localization/leave-local.dart';
import 'package:pos/utils/button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LeaveCard extends StatelessWidget {
  LeaveCard({
    super.key,
    required this.leave,
    required this.textColor,
    required this.subColor,
    this.onDelete,
  });

  final Leave leave;
  final Color textColor;
  final Color subColor;
  final VoidCallback? onDelete;

  final shadOption = {
    'PENDING': LeaveScreenLocale.leavePending,
    'APPROVED': LeaveScreenLocale.leaveApproved,
    'REJECTED': LeaveScreenLocale.leaveRejected,
  };

  @override
  Widget build(BuildContext context) {
    //print("shad value ${leave.status}");
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar
                  LeftGreenBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leave.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            DateFormat('d MMMM yyyy EEEE').format(leave.date),
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 5),
                          RowUserNameWidget(leave: leave),
                          SizedBox(height: 5),
                          Text(leave.user.email),
                          SizedBox(height: 10),
                          Text(
                            LeaveScreenLocale.approvedBy.getString(context),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(leave.approveUser?.firstName ?? "-"),
                              const SizedBox(width: 5),
                              Text(leave.approveUser?.lastName ?? "-"),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(leave.approveUser?.email ?? "-"),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 50,
                            child: ShadSelect(
                              initialValue: leave.status,
                              options: [
                                ShadOption(
                                  value: "PENDING",
                                  child: Text(
                                    shadOption["PENDING"]!.getString(context),
                                  ),
                                ),
                                ShadOption(
                                  value: "APPROVED",
                                  child: Text(
                                    shadOption["APPROVED"]!.getString(context),
                                  ),
                                ),
                                ShadOption(
                                  value: "REJECTED",
                                  child: Text(
                                    shadOption["REJECTED"]!.getString(context),
                                  ),
                                ),
                              ],
                              selectedOptionBuilder: (context, value) =>
                                  Text(shadOption[value]!.getString(context)),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DeleteIcon(onDelete: onDelete),
      ],
    );
  }
}

class RowUserNameWidget extends StatelessWidget {
  const RowUserNameWidget({super.key, required this.leave});

  final Leave leave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(leave.user.firstName ?? "-"),
        const SizedBox(width: 5),
        Text(leave.user.lastName ?? "-"),
      ],
    );
  }
}
