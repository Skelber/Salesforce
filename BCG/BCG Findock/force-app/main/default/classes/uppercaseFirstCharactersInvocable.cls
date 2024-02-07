public class uppercaseFirstCharactersInvocable {

    // Invocable variable to accept a string
    public class InputParameter {
        @InvocableVariable(label='Input String')
        public String inputString;
    }

    // Invocable variable to return the result string
    public class OutputParameter {
        @InvocableVariable(label='Result String')
        public String resultString;
    }

    // Invocable method to uppercase the first character after a space in a string
    @InvocableMethod(label='Uppercase First After Space')
    public static List<OutputParameter> uppercaseFirstAfterSpace(List<InputParameter> inputParameters) {
        List<OutputParameter> outputParameters = new List<OutputParameter>();

        for (InputParameter inputParameter : inputParameters) {
            OutputParameter outputParameter = new OutputParameter();

            if (inputParameter.inputString != null && !String.isBlank(inputParameter.inputString.trim())) {
                // Split the input string by space
                String[] words = inputParameter.inputString.split(' ');

                // Iterate through each word and uppercase the first character
                for (Integer i = 0; i < words.size(); i++) {
                    if (!String.isBlank(words[i])) {
                        words[i] = words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
                    }
                }

                // Join the words back into a single string with spaces
                outputParameter.resultString = String.join(words, ' ');
            } else {
                // Return the input string as is if it's null or empty
                outputParameter.resultString = inputParameter.inputString;
            }

            outputParameters.add(outputParameter);
        }

        return outputParameters;
    }
}
