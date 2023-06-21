(define
    (domain bank-bot)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (know__task)
        (know__account1)
        (know__account2)
        (know__funds)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (allow_single_slot_funds)
        (allow_single_slot_account2)
        (allow_single_slot_account1)
        (task-value-transfer_funds_between_accounts)
    )
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (know__funds)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         confirm-transfer__set-allergy
                (outcome complete-transfer
                    (and
                        (goal)
                        (have-message)
                        (know__funds)
                        (not (know__account2))
                        (force-statement)
                        (not (know__account1))
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (have-message)
                (force-statement)
            )
        :effect
            (labeled-oneof         dialogue_statement__reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action slot-fill__get-task
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         slot-fill__get-task__validate-slot-fill
                (outcome task_found
                    (and
                        (know__task)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action slot-fill__get-transfer-settings
        :parameters()
        :precondition
            (and
                (not (know__funds))
                (not (know__account2))
                (not (force-statement))
                (task-value-transfer_funds_between_accounts)
                (not (know__account1))
                (know__task)
            )
        :effect
            (labeled-oneof         slot-fill__get-transfer-settings__validate-slot-fill
                (outcome account1_found-account2_found-funds_found
                    (and
                        (know__funds)
                        (know__account1)
                        (know__account2)
                    )
                )
                (outcome account1_found-account2_found
                    (and
                        (know__account1)
                        (allow_single_slot_funds)
                        (know__account2)
                    )
                )
                (outcome account1_found-funds_found
                    (and
                        (allow_single_slot_account2)
                        (know__funds)
                        (know__account1)
                    )
                )
                (outcome account1_found
                    (and
                        (allow_single_slot_account2)
                        (know__account1)
                        (allow_single_slot_funds)
                    )
                )
                (outcome account2_found-funds_found
                    (and
                        (allow_single_slot_account1)
                        (know__funds)
                        (know__account2)
                    )
                )
                (outcome account2_found
                    (and
                        (allow_single_slot_account1)
                        (allow_single_slot_funds)
                        (know__account2)
                    )
                )
                (outcome funds_found
                    (and
                        (allow_single_slot_account2)
                        (allow_single_slot_account1)
                        (know__funds)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action single_slot__funds
        :parameters()
        :precondition
            (and
                (not (know__funds))
                (allow_single_slot_funds)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         single_slot__funds__validate-slot-fill
                (outcome fill-slot
                    (and
                        (know__funds)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action single_slot__account2
        :parameters()
        :precondition
            (and
                (allow_single_slot_account2)
                (not (know__account2))
                (not (force-statement))
            )
        :effect
            (labeled-oneof         single_slot__account2__validate-slot-fill
                (outcome fill-slot
                    (and
                        (know__account2)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action single_slot__account1
        :parameters()
        :precondition
            (and
                (not (know__account1))
                (allow_single_slot_account1)
                (not (force-statement))
            )
        :effect
            (labeled-oneof         single_slot__account1__validate-slot-fill
                (outcome fill-slot
                    (and
                        (know__account1)
                    )
                )
                (outcome fallback
                    (and
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action set-task
        :parameters()
        :precondition
            (and
                (not (task-value-transfer_funds_between_accounts))
                (know__task)
            )
        :effect
            (labeled-oneof         set-task__set-valid-value
                (outcome transfer_funds_between_accounts
                    (and
                        (task-value-transfer_funds_between_accounts)
                    )
                )
            )
    )
)