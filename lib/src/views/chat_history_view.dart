// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../chat_view_model/chat_view_model_client.dart';
import '../providers/interface/chat_message.dart';
import 'chat_message_view/chat_message_view.dart';

/// A widget that displays a history of chat messages.
///
/// This widget renders a scrollable list of chat messages, supporting
/// selection and editing of messages. It displays messages in reverse
/// chronological order (newest at the bottom).
class ChatHistoryView extends StatefulWidget {
  /// Creates a [ChatHistoryView].
  ///
  /// If [onEditMessage] is provided, it will be called when a user initiates an
  /// edit action on an editable message (typically the last user message in the
  /// history).
  const ChatHistoryView({
    this.onEditMessage,
    super.key,
  });

  /// Optional callback function for editing a message.
  ///
  /// If provided, this function will be called when a user initiates an edit
  /// action on an editable message (typically the last user message in the
  /// history). The function receives the [ChatMessage] to be edited as its
  /// parameter.
  final void Function(ChatMessage message)? onEditMessage;

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  var _selectedMessageIndex = -1;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: ChatViewModelClient(
          builder: (context, viewModel, child) => ListenableBuilder(
            listenable: viewModel.controller,
            builder: (context, child) {
              final history = viewModel.controller.history.toList();
              return ListView.builder(
                reverse: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final messageIndex = history.length - index - 1;
                  final message = history[messageIndex];
                  final isLastUserMessage = message.origin.isUser &&
                      messageIndex >= history.length - 2;

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ChatMessageView(
                      message: message,
                      onEdit: isLastUserMessage && widget.onEditMessage != null
                          ? () => widget.onEditMessage?.call(message)
                          : null,
                      onSelected: (selected) => _onSelectMessage(
                        messageIndex,
                        selected,
                      ),
                      selected: _selectedMessageIndex == messageIndex,
                    ),
                  );
                },
              );
            },
          ),
        ),
      );

  void _onSelectMessage(int messageIndex, bool selected) =>
      setState(() => _selectedMessageIndex = selected ? messageIndex : -1);
}
