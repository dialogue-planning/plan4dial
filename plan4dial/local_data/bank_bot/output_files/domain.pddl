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
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-transfer__start-task
                (outcome want-transfer
                    (and
                        (know__task)
                    )
                )
                (outcome dont-want
                    (and
                        (force-statement)
                        (tried-transfer)
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
                (task-value-transfer_funds_between_accounts)
            )
        :effect
            (labeled-oneof get-transfer-options__get-options
                (outcome get-valid-options
                    (and
                        (know__account1)
                        (know__account2)
                        (know__funds)
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
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (task-value-transfer_funds_between_accounts)
                (not (force-statement))
                (know__account2)
                (know__account1)
                (know__funds)
            )
        :effect
            (labeled-oneof confirm-transfer__transfer
                (outcome complete
                    (and
                        (not (know__funds))
                        (not (task-value-pay_bills))
                        (not (know__account2))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (tried-transfer)
                        (not (know__task))
                        (not (task-value-request_money))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
            )
    )
    (:action offer-e-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__task))
                (not (tried-e-transfer))
            )
        :effect
            (labeled-oneof offer-e-transfer__start-task
                (outcome want-transfer
                    (and
                        (know__task)
                    )
                )
                (outcome dont-want
                    (and
                        (tried-e-transfer)
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
    (:action get-e-transfer-options
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-e-transfer)
            )
        :effect
            (labeled-oneof get-e-transfer-options__get-options
                (outcome get-valid-e-transfer
                    (and
                        (know__contact)
                        (select-account)
                        (know__funds)
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
    (:action confirm-e-transfer
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__contact)
                (task-value-e-transfer)
                (know__account1)
                (know__funds)
            )
        :effect
            (labeled-oneof confirm-e-transfer__reset
                (outcome complete
                    (and
                        (not (know__contact))
                        (not (know__funds))
                        (not (task-value-pay_bills))
                        (tried-e-transfer)
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (not (know__task))
                        (not (task-value-request_money))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
            )
    )
    (:action offer-request
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__task))
                (not (tried-request-money))
            )
        :effect
            (labeled-oneof offer-request__start-task
                (outcome want-transfer
                    (and
                        (know__task)
                    )
                )
                (outcome dont-want
                    (and
                        (force-statement)
                        (tried-request-money)
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
                (outcome get-valid-request
                    (and
                        (know__contact)
                        (know__funds)
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
    (:action confirm-request
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__contact)
                (know__funds)
                (task-value-request_money)
            )
        :effect
            (labeled-oneof confirm-request__reset
                (outcome complete
                    (and
                        (not (know__contact))
                        (not (know__funds))
                        (not (task-value-pay_bills))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (tried-request-money)
                        (not (know__task))
                        (not (task-value-request_money))
                        (not (task-value-transfer_funds_between_accounts))
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
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-pay__start-task
                (outcome want-pay
                    (and
                        (know__task)
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
                        (not (task-value-pay_bills))
                        (tried-pay-bills)
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (not (know__bill))
                        (not (know__task))
                        (not (task-value-request_money))
                        (not (task-value-transfer_funds_between_accounts))
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
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-cancel__start-task
                (outcome want-cancel
                    (and
                        (know__task)
                    )
                )
                (outcome dont-want
                    (and
                        (force-statement)
                        (have-message)
                        (tried-cancel)
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
                        (tried-cancel)
                        (not (task-value-pay_bills))
                        (not (know__account2))
                        (not (know__account1))
                        (not (task-value-e-transfer))
                        (not (task-value-cancel_account))
                        (not (know__task))
                        (not (task-value-request_money))
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (tried-cancel)
                (not (force-statement))
                (tried-e-transfer)
                (tried-pay-bills)
                (tried-transfer)
                (tried-request-money)
            )
        :effect
            (labeled-oneof complete__finish
                (outcome done
                    (and
                        (goal)
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
                (select-account)
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
                        (force-statement)
                        (have-message)
                        (know__account2)
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
    (:action set-task
        :parameters()
        :precondition
            (and
                (not (task-value-pay_bills))
                (not (task-value-e-transfer))
                (know__task)
                (not (task-value-cancel_account))
                (not (task-value-request_money))
                (not (task-value-transfer_funds_between_accounts))
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