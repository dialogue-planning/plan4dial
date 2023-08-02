(define
    (domain bank-bot)
    (:requirements :strips)
    (:types )
    (:constants )
    (:predicates
        (select-account)
        (know__task)
        (tried-transfer)
        (tried-e-transfer)
        (tried-request-money)
        (tried-pay-bills)
        (tried-create)
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
        (task-value-create_account)
    )
    (:action offer-transfer
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (force-statement))
                (not (tried-transfer))
            )
        :effect
            (labeled-oneof offer-transfer__start-task
                (outcome want-transfer
                    (and
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (know__task)
                        (task-value-transfer_funds_between_accounts)
                        (not (task-value-create_account))
                        (not (task-value-e-transfer))
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-transfer)
                        (force-statement)
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
                        (know__funds)
                        (know__account2)
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
    (:action confirm-transfer
        :parameters()
        :precondition
            (and
                (know__funds)
                (know__account2)
                (not (force-statement))
                (know__account1)
                (task-value-transfer_funds_between_accounts)
            )
        :effect
            (labeled-oneof confirm-transfer__transfer
                (outcome complete
                    (and
                        (not (know__account1))
                        (not (know__account2))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-create_account))
                        (not (know__funds))
                        (not (task-value-e-transfer))
                        (not (task-value-transfer_funds_between_accounts))
                        (tried-transfer)
                        (not (know__task))
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
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-e-transfer__start-task
                (outcome want-transfer
                    (and
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-create_account))
                        (know__task)
                        (task-value-e-transfer)
                        (not (task-value-transfer_funds_between_accounts))
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-e-transfer)
                        (force-statement)
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
                        (know__funds)
                        (select-account)
                        (know__contact)
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
    (:action confirm-e-transfer
        :parameters()
        :precondition
            (and
                (know__contact)
                (know__funds)
                (not (force-statement))
                (know__account1)
                (task-value-e-transfer)
            )
        :effect
            (labeled-oneof confirm-e-transfer__reset
                (outcome complete
                    (and
                        (not (know__account1))
                        (not (know__contact))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-create_account))
                        (tried-e-transfer)
                        (not (know__funds))
                        (not (task-value-e-transfer))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (know__task))
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
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-request__start-task
                (outcome want-transfer
                    (and
                        (not (task-value-pay_bills))
                        (task-value-request_money)
                        (not (task-value-create_account))
                        (know__task)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-e-transfer))
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-request-money)
                        (force-statement)
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
                        (know__funds)
                        (know__contact)
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
    (:action confirm-request
        :parameters()
        :precondition
            (and
                (know__funds)
                (task-value-request_money)
                (not (force-statement))
                (know__contact)
            )
        :effect
            (labeled-oneof confirm-request__reset
                (outcome complete
                    (and
                        (not (know__contact))
                        (tried-request-money)
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-create_account))
                        (not (know__funds))
                        (not (task-value-e-transfer))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (know__task))
                    )
                )
            )
    )
    (:action offer-pay
        :parameters()
        :precondition
            (and
                (not (know__task))
                (not (force-statement))
                (not (tried-pay-bills))
            )
        :effect
            (labeled-oneof offer-pay__start-task
                (outcome want-pay
                    (and
                        (not (task-value-request_money))
                        (task-value-pay_bills)
                        (not (task-value-create_account))
                        (know__task)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-e-transfer))
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-pay-bills)
                        (force-statement)
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
    (:action confirm-bill-payment
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-pay_bills)
                (know__bill)
                (know__account1)
            )
        :effect
            (labeled-oneof confirm-bill-payment__reset
                (outcome complete
                    (and
                        (not (know__account1))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-create_account))
                        (not (know__bill))
                        (tried-pay-bills)
                        (not (task-value-e-transfer))
                        (not (task-value-transfer_funds_between_accounts))
                        (not (know__task))
                    )
                )
            )
    )
    (:action offer-new
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (tried-create))
                (not (know__task))
            )
        :effect
            (labeled-oneof offer-new__start-task
                (outcome want-create
                    (and
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (task-value-create_account)
                        (know__task)
                        (not (task-value-transfer_funds_between_accounts))
                        (not (task-value-e-transfer))
                    )
                )
                (outcome dont-want
                    (and
                        (have-message)
                        (tried-create)
                        (force-statement)
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
    (:action confirm-create
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (know__account2)
                (task-value-create_account)
                (know__account1)
            )
        :effect
            (labeled-oneof confirm-create__reset
                (outcome complete
                    (and
                        (not (know__account1))
                        (not (know__account2))
                        (not (task-value-pay_bills))
                        (not (task-value-request_money))
                        (not (task-value-create_account))
                        (not (task-value-e-transfer))
                        (not (task-value-transfer_funds_between_accounts))
                        (tried-create)
                        (not (know__task))
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (tried-request-money)
                (not (force-statement))
                (tried-e-transfer)
                (tried-pay-bills)
                (tried-create)
                (tried-transfer)
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
                (have-message)
                (force-statement)
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
                (not (know__account1))
                (not (force-statement))
                (select-account)
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
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action slot-fill__get-payment
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-pay_bills)
                (not (know__bill))
            )
        :effect
            (labeled-oneof slot-fill__get-payment__validate-slot-fill
                (outcome bill_found
                    (and
                        (select-account)
                        (know__bill)
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
    (:action slot-fill__get-create
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (task-value-create_account)
                (not (know__account2))
            )
        :effect
            (labeled-oneof slot-fill__get-create__validate-slot-fill
                (outcome account2_found
                    (and
                        (know__account2)
                        (select-account)
                        (have-message)
                        (force-statement)
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
)
