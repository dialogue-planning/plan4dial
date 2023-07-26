(define
    (domain bank-bot)
    (:requirements         :strips :typing)
    (:types )
    (:constants )
    (:predicates
        (select-account)
        (know__task)
        (tried-transfer)
        (tried-e-transfer)
        (tried-request-money)
        (tried-pay-bills)
        (tried-cancel)
        (know__account1)
        (know__account2)
        (know__funds)
        (know__contact)
        (know__bill)
        (know__goal)
        (goal)
        (have-message)
        (force-statement)
        (task-value-transfer_funds_between_accounts)
        (task-value-e-transfer)
        (task-value-request_money)
        (task-value-pay_bills)
        (task-value-cancel_account)
    )
    (:action offer-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (tried-transfer))
            )
        :effect
            (labeled-oneof offer-transfer__start-task
                (outcome want-transfer
                    (and
                        (tried-transfer)
                    )
                )
                (outcome dont-want
                    (and
                        (tried-transfer)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-transfer-options
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-e-transfer)
            )
        :effect
            (labeled-oneof get-transfer-options__get-options
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__funds)
                (task-value-e-transfer)
                (know__account1)
                (know__contact)
            )
        :effect
            (labeled-oneof confirm-transfer__reset
                (outcome complete
                    (and
                        (not (know__account1))
                        (not (know__task))
                        (not (know__funds))
                        (not (task-value-pay_bills))
                        (not (task-value-e-transfer))
                        (not (know__contact))
                        (not (task-value-cancel_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action offer-e-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (tried-e-transfer))
            )
        :effect
            (labeled-oneof offer-e-transfer__start-task
                (outcome want-transfer
                    (and
                        (tried-e-transfer)
                    )
                )
                (outcome dont-want
                    (and
                        (force-statement)
                        (tried-e-transfer)
                        (have-message)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action offer-request
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (tried-request-money))
            )
        :effect
            (labeled-oneof offer-request__start-task
                (outcome want-transfer
                    (and
                        (tried-request-money)
                    )
                )
                (outcome dont-want
                    (and
                        (tried-request-money)
                        (force-statement)
                        (have-message)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action get-request-options
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-request_money)
            )
        :effect
            (labeled-oneof get-request-options__get-options
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-request
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__funds)
                (know__contact)
                (task-value-request_money)
            )
        :effect
            (labeled-oneof confirm-request__reset
                (outcome complete
                    (and
                        (not (know__task))
                        (not (know__funds))
                        (not (task-value-pay_bills))
                        (not (task-value-e-transfer))
                        (not (know__contact))
                        (not (task-value-cancel_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action offer-pay
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (tried-pay-bills))
            )
        :effect
            (labeled-oneof offer-pay__start-task
                (outcome want-pay
                    (and
                        (tried-pay-bills)
                    )
                )
                (outcome dont-want
                    (and
                        (force-statement)
                        (have-message)
                        (tried-pay-bills)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-bill-payment
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-pay_bills)
                (know__bill)
            )
        :effect
            (labeled-oneof confirm-bill-payment__reset
                (outcome complete
                    (and
                        (not (know__task))
                        (not (task-value-pay_bills))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-request_money))
                        (not (know__bill))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action offer-cancel
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (tried-cancel))
            )
        :effect
            (labeled-oneof offer-cancel__start-task
                (outcome want-cancel
                    (and
                        (tried-cancel)
                    )
                )
                (outcome dont-want
                    (and
                        (force-statement)
                        (tried-cancel)
                        (have-message)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action confirm-cancel
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-cancel_account)
                (know__account1)
                (know__account2)
            )
        :effect
            (labeled-oneof confirm-cancel__reset
                (outcome complete
                    (and
                        (not (know__account1))
                        (not (know__task))
                        (not (task-value-pay_bills))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (know__account2))
                        (not (task-value-request_money))
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (tried-pay-bills)
                (tried-e-transfer)
                (tried-request-money)
                (tried-transfer)
                (tried-cancel)
            )
        :effect
            (labeled-oneof complete__finish
                (outcome done
                    (and
                        (goal)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action dialogue_statement
        :parameters()
        :precondition
            (and
                (force-statement)
                (have-message)
            )
        :effect
            (labeled-oneof dialogue_statement__reset
                (outcome lock
                    (and
                        (not (force-statement))
                        (not (have-message))
                    )
                )
            )
    )
    (:action slot-fill__select-account
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__account1))
            )
        :effect
            (labeled-oneof slot-fill__select-account__validate-slot-fill
                (outcome account1_found
                    (and
                        (not (select-account))
                        (know__account1)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-payment
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__bill))
            )
        :effect
            (labeled-oneof slot-fill__get-payment__validate-slot-fill
                (outcome bill_found
                    (and
                        (know__bill)
                        (select-account)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action slot-fill__get-cancel
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__account2))
            )
        :effect
            (labeled-oneof slot-fill__get-cancel__validate-slot-fill
                (outcome account2_found
                    (and
                        (have-message)
                        (force-statement)
                        (select-account)
                        (know__account2)
                    )
                )
                (outcome fallback
                    (and
                        (force-statement)
                        (have-message)
                    )
                )
            )
    )
    (:action set-task
        :parameters()
        :precondition
            (and
                (not (task-value-pay_bills))
                (not (task-value-e-transfer))
                (not (task-value-cancel_account))
                (not (task-value-transfer_funds_between_accounts))
                (not (task-value-request_money))
                (know__task)
            )
        :effect
            (labeled-oneof set-task__set-valid-value
                (outcome transfer_funds_between_accounts
                    (and
                        (task-value-transfer_funds_between_accounts)
                    )
                )
                (outcome e-transfer
                    (and
                        (task-value-e-transfer)
                    )
                )
                (outcome request_money
                    (and
                        (task-value-request_money)
                    )
                )
                (outcome pay_bills
                    (and
                        (task-value-pay_bills)
                    )
                )
                (outcome cancel_account
                    (and
                        (task-value-cancel_account)
                    )
                )
            )
    )
)