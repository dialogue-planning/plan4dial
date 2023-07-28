(define
    (domain medical_bot)
    (:requirements :strips)
    (:types )
    (:constants )
    (:predicates
        (know__covid-exposure)
        (covid-exposure)
        (know__have-symptoms)
        (have-symptoms)
        (know__exposure-period-over-5)
        (exposure-period-over-5)
        (know__positive-30)
        (positive-30)
        (know__positive-90)
        (positive-90)
        (know__should-test)
        (should-test)
        (goal)
        (have-message)
        (force-statement)
    )
    (:action determine_test
        :parameters()
        :precondition
            (and
                (know__positive-90)
                (know__have-symptoms)
                (know__exposure-period-over-5)
                (know__covid-exposure)
                (know__positive-30)
                (not (force-statement))
            )
        :effect
            (labeled-oneof determine_test__check-test
                (outcome no-symptom-exposed-been-5
                    (and
                        (should-test)
                        (know__should-test)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome no-symptom-exposed-less-5
                    (and
                        (know__should-test)
                        (have-message)
                        (force-statement)
                        (not (should-test))
                    )
                )
                (outcome have-symptoms-no-90
                    (and
                        (should-test)
                        (know__should-test)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome have-symptoms-30
                    (and
                        (should-test)
                        (know__should-test)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome have-no-symptoms-30
                    (and
                        (know__should-test)
                        (have-message)
                        (force-statement)
                        (not (should-test))
                    )
                )
                (outcome have-symptoms-90
                    (and
                        (should-test)
                        (know__should-test)
                        (have-message)
                        (force-statement)
                    )
                )
                (outcome have-no-symptoms-90
                    (and
                        (should-test)
                        (know__should-test)
                        (have-message)
                        (force-statement)
                    )
                )
            )
    )
    (:action complete
        :parameters()
        :precondition
            (and
                (know__should-test)
                (not (force-statement))
            )
        :effect
            (labeled-oneof complete__finish
                (outcome finish
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
                        (not (have-message))
                        (not (force-statement))
                    )
                )
            )
    )
    (:action slot-fill__get_covid_exposure
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__covid-exposure))
            )
        :effect
            (labeled-oneof slot-fill__get_covid_exposure__get-response
                (outcome confirm_outcome
                    (and
                        (covid-exposure)
                        (know__covid-exposure)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (covid-exposure))
                        (know__covid-exposure)
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
    (:action slot-fill__get_have_symptoms
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__have-symptoms))
                (know__covid-exposure)
            )
        :effect
            (labeled-oneof slot-fill__get_have_symptoms__get-response
                (outcome confirm_outcome
                    (and
                        (know__have-symptoms)
                        (have-symptoms)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__have-symptoms)
                        (not (have-symptoms))
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
    (:action slot-fill__get_exposure_period
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__exposure-period-over-5))
                (know__covid-exposure)
            )
        :effect
            (labeled-oneof slot-fill__get_exposure_period__get-response
                (outcome confirm_outcome
                    (and
                        (exposure-period-over-5)
                        (know__exposure-period-over-5)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (exposure-period-over-5))
                        (know__exposure-period-over-5)
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
    (:action slot-fill__get_positive_30
        :parameters()
        :precondition
            (and
                (not (force-statement))
                (not (know__positive-30))
                (know__covid-exposure)
            )
        :effect
            (labeled-oneof slot-fill__get_positive_30__get-response
                (outcome confirm_outcome
                    (and
                        (know__positive-30)
                        (positive-30)
                    )
                )
                (outcome deny_outcome
                    (and
                        (know__positive-30)
                        (not (positive-30))
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
    (:action slot-fill__get_positive_90
        :parameters()
        :precondition
            (and
                (know__positive-30)
                (not (know__positive-90))
                (not (force-statement))
            )
        :effect
            (labeled-oneof slot-fill__get_positive_90__get-response
                (outcome confirm_outcome
                    (and
                        (positive-90)
                        (know__positive-90)
                    )
                )
                (outcome deny_outcome
                    (and
                        (not (positive-90))
                        (know__positive-90)
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