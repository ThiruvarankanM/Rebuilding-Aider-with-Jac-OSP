from aider.dump import dump  # noqa: F401
from aider.utils import format_messages


def sanity_check_messages(messages):
    """
    Validate message sequence:
    - Must alternate between 'user' and 'assistant' roles.
    - 'system' messages are allowed anywhere.
    - Last non-system message must be from 'user'.

    Args:
        messages (list[dict]): List of messages with 'role' and 'content'.

    Returns:
        bool: True if valid, False otherwise.
    """
    last_role = None
    last_non_system_role = None

    for msg in messages:
        role = msg.get("role")
        if role not in {"user", "assistant", "system"}:
            raise ValueError(f"Invalid role detected: {role}")

        if role == "system":
            continue

        if last_role and role == last_role:
            turns = format_messages(messages)
            raise ValueError(
                "Messages don't properly alternate user/assistant:\n\n" + turns
            )

        last_role = role
        last_non_system_role = role

    return last_non_system_role == "user"


def ensure_alternating_roles(messages):
    """
    Ensure messages alternate between 'assistant' and 'user' roles.

    - Inserts empty placeholder messages when two consecutive
      messages share the same role.
    - Keeps 'system' messages in place.

    Args:
        messages (list[dict]): Messages with 'role' and 'content'.

    Returns:
        list[dict]: Fixed list of alternating messages.
    """
    if not messages:
        return []

    fixed_messages = []
    prev_role = None

    for msg in messages:
        current_role = msg.get("role")

        # Pass through system messages without altering alternation
        if current_role == "system":
            fixed_messages.append(msg)
            continue

        # Insert placeholder if consecutive roles are identical
        if current_role == prev_role:
            opposite_role = "assistant" if current_role == "user" else "user"
            fixed_messages.append({"role": opposite_role, "content": ""})

        fixed_messages.append(msg)
        prev_role = current_role

    return fixed_messages
